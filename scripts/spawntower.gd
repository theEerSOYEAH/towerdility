extends Button

@export var smiles : int = GameManager.smiles

@export var cost = 0
@export var ghost_tower_scene : PackedScene
@export var real_tower_scene : PackedScene

@export var hotkey : Key = KEY_NONE

func _on_pressed() -> void:
	if GameManager.smiles < cost:
		return
	if get_tree().root.has_node("GhostTower"):
		return
	
	var ghost = ghost_tower_scene.instantiate()
	
	ghost.real_tower_scene = real_tower_scene
	ghost.cost = cost
	
	get_tree().root.add_child(ghost)
func extract_smiles():
	GameManager.spend_smiles(cost)
		


func _unhandled_input(event):
	if hotkey == KEY_NONE:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == hotkey:
		_on_pressed()
