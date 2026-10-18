extends Control

@onready var dim = $Dim
@onready var title_label = $Sprite2D/TitleLabel
@onready var wave_label = $WaveLabel
@onready var restart_button = $RestartButton
@onready var menu_button = $MenuButton

func _ready():
	hide()
	GameManager.game_over.connect(_on_game_over)
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	
func _on_game_over():
	wave_label.text = "You reached wave " + str(GameManager.wave)
	show()
	get_tree().paused = true
	
	var items = [title_label, wave_label, restart_button, menu_button]
	dim.modulate.a = 0.0
	for item in items:
		item.modulate.a = 0.0
		item.scale = Vector2(0.9, 0.9)
		item.pivot_offset = item.size / 2
	
	var tw = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	tw.tween_property(dim, "modulate:a", 1.0, 0.5)
	
	for item in items:
		tw.tween_property(item, "modulate:a", 1.0, 0.3)
		tw.parallel().tween_property(item, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
	
func _on_restart_pressed():
	get_tree().paused = false
	GameManager.reset()
	get_tree().reload_current_scene()

func _on_menu_pressed():
	get_tree().paused = false
	GameManager.reset()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
