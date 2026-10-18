extends Control

@onready var play_button = $PlayButton
@onready var endless_button = $EndlessButton
@onready var quit_button = $QuitButton

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	endless_button.pressed.connect(_on_endless_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	GameManager.reset()
	GameManager.endless_mode = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_endless_pressed():
	GameManager.reset()
	GameManager.endless_mode = true
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed():
	get_tree().quit()
