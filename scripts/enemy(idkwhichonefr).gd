extends CharacterBody2D

var smiles = 0
@export var speed = 40
@export var max_health = 10
var current_health  : int

var path_follow : PathFollow2D = null

func _ready() -> void:
	current_health = max_health
	if get_parent() is PathFollow2D:
		path_follow = get_parent()

func _process(delta: float) -> void:
	if path_follow:
		path_follow.progress += speed * delta
		
		if path_follow.progress_ratio >= 1.0:
			reach_base()

func take_damage(amount: int):
	current_health -= amount
	if current_health <= 0:
		die()

func reach_base():
	path_follow.queue_free()

func die():
	GameManager.add_smiles(1)
	path_follow.queue_free()
