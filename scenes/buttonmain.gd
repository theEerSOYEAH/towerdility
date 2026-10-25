extends Button


@export_file("*.tscn") var map_scene : String

func _ready() -> void:
	pressed.connect(_on_pressed)
	
	

func _on_pressed() -> void:
	if map_scene == "":
		print("nomapscene")
		return
	get_tree().change_scene_to_file(map_scene)
