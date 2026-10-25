extends Node

var endless_mode = false
var health = 100

const SAVE_PATH = "user://save.json"
var load_pending = false
var loaded_data = {}


signal game_over
var wave = 0
var is_over = false

var smiles = 60
var popup_layer = null


func add_smiles(amount, pos = null):
	smiles += amount
	show_popup(amount, pos)


func spend_smiles(amount):
	if smiles >= amount:
		smiles -= amount
		show_popup(-amount)
		return true
	return false

func reset():
	smiles = 60
	health = 100
	wave = 0
	is_over = false
	load_pending = false
	loaded_data = {}

func get_popup_layer():
	if popup_layer == null or not is_instance_valid(popup_layer):
		popup_layer = CanvasLayer.new()
		popup_layer.layer = 128
		get_tree().current_scene.add_child(popup_layer)
	return popup_layer

func show_popup(amount, pos = null):
	var scene = get_tree().current_scene
	if scene == null:
		return
	
	var screen_pos
	if pos == null:
		screen_pos = scene.get_viewport().get_mouse_position()
	else:
		screen_pos = scene.get_viewport().get_canvas_transform() * pos
	
	var label = Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if amount >= 0:
		label.text = "+" + str(amount)
		label.add_theme_color_override("font_color", Color(0.45, 1.0, 0.45))
	else:
		label.text = str(amount)
		label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_outline_color", Color(0.1, 0.2, 0.1))
	label.add_theme_constant_override("outline_size", 6)
	
	get_popup_layer().add_child(label)
	label.position = screen_pos + Vector2(randf_range(-20, 20), randf_range(-20, 20))
	
	var tw = label.create_tween().set_parallel(true)
	tw.tween_property(label, "position:y", label.position.y - 35, 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(label, "modulate:a", 0.0, 0.5).set_delay(0.4)
	tw.chain().tween_callback(label.queue_free)
	
func lose_health(amount):
	if is_over:
		return
	health -= amount
	print("base health: ", health)
	
	if health <= 0:
		health = 0
		is_over = true
		delete_save()
		game_over.emit()

func has_save():
	return FileAccess.file_exists(SAVE_PATH)

func delete_save():
	if has_save():
		DirAccess.open("user://").remove("save.json")

func save_game(spawner):
	var tower_list = []
	for t in get_tree().get_nodes_in_group("towers"):
		if not is_instance_valid(t) or t.is_queued_for_deletion():
			continue
		if t.scene_file_path == "" or not t.has_method("get_save_data"):
			continue
		tower_list.append({
			"scene": t.scene_file_path,
			"x": t.global_position.x,
			"y": t.global_position.y,
			"data": t.get_save_data()
		})
	
	var data = {
		"smiles": smiles,
		"health": health,
		"endless": endless_mode,
		"wave": spawner.current_wave,
		"towers": tower_list
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data))
	file.close()

func prepare_load():
	if not has_save():
		return false
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(data) != TYPE_DICTIONARY:
		return false
	loaded_data = data
	endless_mode = bool(data.get("endless", false))
	load_pending = true
	return true

func apply_save(spawner):
	if not load_pending:
		return
	load_pending = false
	
	smiles = int(loaded_data.get("smiles", 0))
	health = int(loaded_data.get("health", 100))
	spawner.current_wave = int(loaded_data.get("wave", 0))
	wave = spawner.current_wave
	
	while spawner.waves.size() < spawner.current_wave:
		spawner.waves.append([])
	
	for entry in loaded_data.get("towers", []):
		var scene = load(entry["scene"])
		if scene == null:
			continue
		var t = scene.instantiate()
		get_tree().current_scene.add_child(t)
		t.global_position = Vector2(entry["x"], entry["y"])
		t.add_to_group("towers")
		if t.has_method("apply_save_data"):
			t.apply_save_data(entry.get("data", {}))
		
	loaded_data = {}
