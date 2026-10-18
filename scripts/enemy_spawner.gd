extends Node2D

@export var path_2d: Path2D
@export var enemy_types: Array[PackedScene]
@export var time_between_waves = 3.0
@export var auto_next_wave = false


const VERITY = 0
const FALSITY = 1
const OBESITY = 2

var waves = []
var current_wave = 0
var wave_running = false

func _ready() -> void:
	waves = [
		[group(VERITY, 5)],
		[group(VERITY, 5), group(FALSITY, 5)],
		[group(VERITY, 5), group(OBESITY, 5, true, true, 0.3)],
	]

func group(type, count, camo = false, metal = false, delay = 0.5):
	return {"type": type, "count": count, "camo": camo, "metal": metal, "delay": delay}

func start_next_wave():
	if wave_running:
		return
	if get_tree().get_nodes_in_group("enemies").size() > 0:
		print("kill all enemioes first")
		return
	if current_wave >= waves.size():
		print("all waves finished")
		return
		
	wave_running = true
	
	for g in waves[current_wave]:
		for i in g["count"]:
			spawn_enemy(g)
			await get_tree().create_timer(g["delay"]).timeout
	
	current_wave += 1
	wave_running = false
	
	if auto_next_wave:
		await get_tree().create_timer(time_between_waves).timeout
		start_next_wave()
		
func spawn_enemy(g):
	var new_path_follow = PathFollow2D.new()
	new_path_follow.loop = false
	new_path_follow.rotates = true
	
	var enemy_instance = enemy_types[g["type"]].instantiate()
	enemy_instance.is_camo = g["camo"]
	enemy_instance.is_metal = g["metal"]
	
	new_path_follow.add_child(enemy_instance)
	path_2d.add_child(new_path_follow)

func _on_enemy_spawn_button_pressed():
	start_next_wave()
	
