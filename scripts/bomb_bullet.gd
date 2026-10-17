extends Area2D


@export var speed = 300
@export var explosion_radius = 20
@export var damage = 25
@export var damage_type = "explosive"

var target : Node2D = null
var target_position : Vector2

func _ready() -> void:
	if is_instance_valid(target):
		target_position = target.global_position
	else:
		target_position = global_position

func _process(delta: float) -> void:
	global_position = global_position.move_toward(target_position, speed * delta)
	
	if global_position.distance_to(target_position) < 0.5:
		explode()

func explode():
	print("exploded")
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var circle = CircleShape2D.new()
	circle.radius = explosion_radius
	query.shape = circle
	query.transform = Transform2D(0, global_position)
	query.collision_mask = 2
	
	var results = space_state.intersect_shape(query)
	
	for result in results:
		var body = result.collider
		if body.is_in_group("enemies"):
			if body.has_method("take_damage"):
				body.take_damage(damage, damage_type)
			print("hit bomb enemie ", body.name)
	queue_free()
