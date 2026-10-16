extends Button

@export var smiles : int = GameManager.smiles

@export var ghost_tower_scene : PackedScene

func _on_pressed() -> void:
	if smiles >= 10:
		smiles -= 10
		if get_tree().root.has_node("GhostTower"):
			return
		get_tree().root.add_child(ghost_tower_scene.instantiate())
	else:
		print("sorry bro ","u have " ,smiles, " smiles")
