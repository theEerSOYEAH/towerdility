extends CharacterBody2D


@export var speed = 40
@export var max_health = 10
@export var reward = 10
@export var is_metal = false
@export var is_camo = false

@export var minion_damage = 1
var blocked = false

var slow_factor :float = 1.0
var slow_time :float = 0.0

var last_source = null

var current_health  : int
var is_dying = false
var path_follow : PathFollow2D = null

func _ready() -> void:
	current_health = max_health
	if get_parent() is PathFollow2D:
		path_follow = get_parent()
	
	if is_metal:
		modulate = Color(0.6, 0.7, 0.9)
	if is_camo:
		modulate.a = 0.5

func _process(delta: float) -> void:
	_update_slow(delta)
	
	if path_follow and not blocked:
		path_follow.progress += speed * slow_factor * delta
		
		if path_follow.progress_ratio >= 1.0:
			reach_base()

func take_damage(amount, damage_type = "sharp", source = null):
	if is_dying:
		return
		
	if is_metal and damage_type == "sharp":
		return
	
	last_source = source
	current_health -= amount
	
	if current_health <= 0:
		die()

func apply_slow(factor : float, duration : float):
	slow_factor = factor
	slow_time = duration
	modulate = Color(0.5, 0.8, 1.0)

func _update_slow(delta: float):
	if slow_time > 0.0:
		slow_time -= delta
		if slow_time <= 0.0:
			slow_factor = 1.0
			modulate = Color(1, 1, 1)
			

func reach_base():
	if is_dying:
		return
	is_dying = true
	GameManager.lose_health(current_health)
	path_follow.queue_free()

func die():
	is_dying = true
	GameManager.add_smiles(reward, global_position)
	if is_instance_valid(last_source) and last_source.has_method("on_enemy_killed"):
		last_source.on_enemy_killed(global_position)
	path_follow.queue_free()
