extends Node

var endless_mode = false
var health = 100


signal game_over
var wave = 0
var is_over = false

var smiles = 0


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
	smiles = 0
	health = 100

func show_popup(amount, pos = null):
	var scene = get_tree().current_scene
	if scene == null:
		return
	if pos == null:
		pos = scene.get_global_mouse_position()
	
	var label = Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 100
	
	if amount > 0:
		label.text = "+" + str(amount)
		label.add_theme_color_override("font_color", Color(0.45, 1.0, 0.45))
	else:
		label.text = str(amount)
		label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_outline_color", Color(0.1, 0.2, 0.1))
	label.add_theme_constant_override("outline_size", 4)
	
	scene.add_child(label)
	label.global_position = pos + Vector2(randf_range(-12, 12), randf_range(-12, 12))
	
	var tw = label.create_tween().set_parallel(true)
	tw.tween_property(label, "position:y", label.position.y -14, 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
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
		game_over.emit()
