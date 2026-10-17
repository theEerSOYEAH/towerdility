extends CharacterBody2D


@export var speed = 40
@export var max_health = 10
@export var reward = 1
@export var is_metal = false
@export var is_camo = false

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
	if path_follow:
		path_follow.progress += speed * delta
		
		if path_follow.progress_ratio >= 1.0:
			reach_base()

func take_damage(amount, damage_type = "sharp"):
	if is_dying:
		return
		
	if is_metal and damage_type == "sharp":
		return
	
	current_health -= amount
	
	if current_health <= 0:
		die()

func reach_base():
	path_follow.queue_free()

func die():
	is_dying = true
	GameManager.add_smiles(reward)
	path_follow.queue_free()
