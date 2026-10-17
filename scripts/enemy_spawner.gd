extends Node2D

@export var path_2d: Path2D
@export var waves: Array[Wave] = []
@export var auto_next_wave = false

var current_wave = 0
var wave_running = false

func start_next_wave():
	if wave_running:
		return
	if current_wave >= waves.size():
		print("all waves finished")
		return
		
	wave_running = true
	var wave = waves[current_wave]
	
	for group in wave.groups:
		for i in group.count:
			spawn_enemy(group)
			await get_tree().create_timer(group.spawn_delay).timeout
	
	current_wave += 1
	wave_running = false
	
	if auto_next_wave:
		await get_tree().create_timer(wave.time_after_wave).timeout
		start_next_wave()
		
func spawn_enemy(group):
	var new_path_follow = PathFollow2D.new()
	new_path_follow.loop = false
	new_path_follow.rotates = true
	
	var enemy_instance = group.enemy_scene.instantiate()
	
	enemy_instance.is_camo = group.is_camo
	enemy_instance.is_metal = group.is_metal
	
	new_path_follow.add_child(enemy_instance)
	path_2d.add_child(new_path_follow)

func _on_enemy_spawn_button_pressed():
	start_next_wave()
	
