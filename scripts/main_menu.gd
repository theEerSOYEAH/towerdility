extends Control

@onready var play_button = $PlayButton
@onready var endless_button = $EndlessButton
@onready var quit_button = $QuitButton
@onready var continue_button = $ContinueButton

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	endless_button.pressed.connect(_on_endless_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	continue_button.visible = GameManager.has_save()
	
	
func _on_play_pressed():
	GameManager.reset()
	GameManager.endless_mode = false
	get_tree().change_scene_to_file("res://scenes/map_selector.tscn")

func _on_endless_pressed():
	GameManager.reset()
	GameManager.endless_mode = true
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_continue_pressed():
	GameManager.reset()
	if GameManager.prepare_load():
		get_tree().change_scene_to_file("res://scenes/main.tscn")
