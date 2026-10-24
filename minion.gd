extends Node2D

var damage = 1
var damage_type := "magic"
var can_see_camo := false
var home := Vector2.ZERO
var leash := 120.0
var lifetime := 12.0

@export var speed := 70
@export var hit_cooldown := 0.6
@export var max_hits := 6

var cd := 0.0
var hit := 0

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return
			
	cd -= delta
	
	
	var target = find_target()
	if target :
		var to = target.global_position - global_position
		if to.length() > 8.0:
			global_position += to.normalized() * speed * delta
			$AnimatedSprite2D.flip_h = to.x < 0
		elif cd <= 0.0:
			target.take_damage(damage, damage_type)
			cd = hit_cooldown
			hit += 1
			if hit >= max_hits:
				queue_free()
		else:
			var back = home - global_position
			if back.length() > 25:
				global_position += back.normalized() * speed * 0.5 * delta

func find_target():
	var best = null
	var best_d := INF
	for e in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e) or e.is_dying:
			continue
		if e.is_camo and not can_see_camo:
			continue
		if e.global_position.distance_to(home) > leash:
			continue
		var d = global_position.distance_to(e.global_position)
		if d < best_d:
			best_d = d
			best = e
	return best
