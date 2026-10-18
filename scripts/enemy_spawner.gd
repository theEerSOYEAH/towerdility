extends Node2D

@export var path_2d: Path2D
@export var enemy_types: Array[PackedScene]
@export var time_between_waves = 3.0
@export var auto_next_wave = false


const VERITY = 0
const FALSITY = 1
const OBESITY = 2
const LOVITY = 3
const MOGGITY = 4
const CRUELITY = 5

var waves = []
var current_wave = 0
var wave_running = false
var handmade_count = 0
var hp_multiplier = 1.0

func _ready() -> void:
	waves = [
		[group(VERITY, 5)],
		[group(VERITY, 5), group(FALSITY, 5)],
		[group(VERITY, 5), group(OBESITY, 1)],
		[group(VERITY, 15)],
		[group(LOVITY, 25)],
		[group(VERITY, 10),group(FALSITY, 10), group(OBESITY, 3)],
		[]
	]
	
	if GameManager.endless_mode:
		waves = []
	handmade_count = waves.size()

func group(type, count, camo = false, metal = false, delay = 0.5, pack_size = 1):
	return{"type": type, "count": count, "camo": camo, "metal": metal, "delay": delay, "pack_size": pack_size}

func pack(type, packs, camo = false, metal = false, delay = 1.5):
	return group(type, packs, camo, metal, delay, 5)
	handmade_count = waves.size()
	
func group(type, count, camo = false, metal = false, delay = 0.5):
	return {"type": type, "count": count, "camo": camo, "metal": metal, "delay": delay}

func start_next_wave():
	if wave_running:
		return
	if get_tree().get_nodes_in_group("enemies").size() > 0:
		print("kill all enemioes first")
		return
	if current_wave >= waves.size():
		if GameManager.endless_mode:
			var n = current_wave - handmade_count + 1
			waves.append(make_endless_waves(n))
		else:
			print("all waves finished")
			return
		
	wave_running = true
	GameManager.wave = current_wave + 1
	
	for g in waves[current_wave]:
		for i in g["count"]:
			for j in g["pack_size"]:
				spawn_enemy(g)
				if g["pack_size"] > 1:
					await  get_tree().create_timer(0.12).timeout
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
	enemy_instance.max_health = int(enemy_instance.max_health * hp_multiplier)
	enemy_instance.is_camo = g["camo"]
	enemy_instance.is_metal = g["metal"]
	
	new_path_follow.add_child(enemy_instance)
	path_2d.add_child(new_path_follow)

func make_endless_waves(n):
	hp_multiplier = 1.0 + n * 0.15
	
	var delay = max(0.15, 0.5 - n * 0.02)
	var wave = []
	
	wave.append(group(VERITY, 5 + n * 2, false, false, delay))
	
	if n >= 2:
		wave.append(group(FALSITY, n * 2, false, false, delay))
	if n >= 4:
		wave.append(group(VERITY, n, true, false, delay))
	if n >= 6:
		wave.append(group(FALSITY, n, false, true, delay))
	if n >= 8:
		wave.append(group(OBESITY, n / 2, true, true, delay))
	
	return wave
func _on_enemy_spawn_button_pressed():
	start_next_wave()
	


func _on_button_pressed() -> void:
	pass # Replace with function body.
