extends Button

@export var smiles : int = GameManager.smiles

@export var ghost_tower_scene : PackedScene
@export var real_tower_scene : PackedScene

@export var hotkey : Key = KEY_NONE

func _on_pressed() -> void:
	if get_tree().root.has_node("GhostTower"):
		return
	
	var ghost = ghost_tower_scene.instantiate()
	
	ghost.real_tower_scene = real_tower_scene
	
	get_tree().root.add_child(ghost)

func _unhandled_input(event):
	if hotkey == KEY_NONE:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == hotkey:
		_on_pressed()
