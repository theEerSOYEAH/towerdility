extends Node2D

@export var enemy_scene : PackedScene
@export var path_2d: Path2D

func _ready():
	spawn_enemy()

func spawn_enemy():
	var new_path_follow = PathFollow2D.new()
	new_path_follow.loop = false
	new_path_follow.rotates = true
	
	var enemy_instance = enemy_scene.instantiate()
	
	new_path_follow.add_child(enemy_instance)
	path_2d.add_child(new_path_follow)
	
