extends Area2D


@export var speed = 500
@export var damage = 1
@export var max_distance = 300
@export var rotation_offest_degrees = 0

var tracking = 0.0
var can_see_camo = false
var homing_target = null


var damage_type = "sharp"
var direction = Vector2.ZERO
var travelled = 0.0
var target: Node2D = null

func _ready():
	body_entered.connect(_on_body_entered)
	face_direction()

func face_direction():
	if direction.length() > 0.01:
		rotation = direction.angle() + deg_to_rad(rotation_offest_degrees)


func _physics_process(delta):
	
	if is_instance_valid(target):
		direction = (target.global_position - global_position).normalized()
		face_direction()
	
	if tracking > 0.0:
		if not is_instance_valid(homing_target):
			homing_target = find_homing_target()
		if homing_target:
			var want = (homing_target.global_position - global_position).normalized()
			var max_turn = tracking * delta
			direction = direction.rotated(clamp(direction.angle_to(want), -max_turn, max_turn))
			rotation = direction.angle()
	
	var step = direction * speed * delta
	global_position += step
	travelled += step.length()
	
	
	if travelled >= max_distance:
		queue_free()
		
func _on_body_entered(body) -> void:
	if not body.is_in_group("enemies"):
		return
	if is_instance_valid(target) and body != target:
		return
	body.take_damage(damage, damage_type)
	queue_free()

func find_homing_target():
	var best = null
	var best_dist = 150.0
	for e in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e):
			continue
		if e.is_camo and not can_see_camo:
			continue
		var d = global_position.distance_to(e.global_position)
		if d < best_dist:
			best_dist = d
			best = e
	return best
