extends Area2D


@export var value = 1
var collected = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_event.connect(_on_input_event)


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		collect()
		


func collect():
	if collected:
		return
	GameManager.add_smiles(value, global_position)
	queue_free()
