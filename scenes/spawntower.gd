extends Button

@export var smiles : int = GameManager.smiles

@export var ghost_tower_scene : PackedScene
@export var real_tower_scene : PackedScene


func _on_pressed() -> void:
	if get_tree().root.has_node("GhostTower"):
		return
	
	var ghost = ghost_tower_scene.instantiate()
	
	ghost.real_tower_scene = real_tower_scene
	
	get_tree().root.add_child(ghost)
