extends Node2D

var damage = 1
var damage_type := "magic"
var can_see_camo := false
var home := Vector2.ZERO
var leash := 120.0
var lifetime := 12.0

@export var speed := 70
@export var max_health = 5
@export var hit_cooldown := 0.6

@export var touch_distance = 14

var path_follow : PathFollow2D
var health : int
var cd := 0.0
var hit := 0
var target = null

func _ready() -> void:
	rotation = PI
	health = max_health
	path_follow = get_parent()

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0.0 or path_follow.progress_ratio <= 0.0:
		die()
		return
			
	if not is_instance_valid(target) or target.is_dying:
		release_target()
		target = find_target()
	
	if target :
		target.take_damage(health, damage_type)
		die()
	else:
		path_follow.progress -= speed * delta
		




func find_target():
	var best = null
	var best_gap := INF
	for e in get_tree().get_nodes_in_group("enemies"):
		
		if not is_instance_valid(e) or e.is_dying:
			continue
		if e.is_camo and not can_see_camo:
			continue
		var gap = global_position.distance_to(e.global_position)
		if gap <= touch_distance and gap < best_gap:
			best_gap = gap
			best = e
	return best	



func release_target():
	if is_instance_valid(target):
		target.blocked = false
	target = null




func die():
	release_target()
	path_follow.queue_free()
