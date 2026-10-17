extends CharacterBody2D

var smiles = 0
@export var speed = 40
@export var max_health = 10
var current_health  : int

var slow_factor :float = 1.0
var slow_time :float = 0.0

var path_follow : PathFollow2D = null

func _ready() -> void:
	current_health = max_health
	if get_parent() is PathFollow2D:
		path_follow = get_parent()

func _process(delta: float) -> void:
	_update_slow(delta)
	
	if path_follow:
		path_follow.progress += speed * slow_factor * delta
		
		if path_follow.progress_ratio >= 1.0:
			reach_base()

func take_damage(amount: int):
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
	path_follow.queue_free()

func die():
	GameManager.add_smiles(1)
	path_follow.queue_free()
