extends Node

var endless_mode = false
var health = 100


signal game_over
var wave = 0
var is_over = false

var smiles = 0
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
	smiles = 0
	health = 100
	wave = 0
	is_over = false

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
		game_over.emit()
