extends Area2D

@export var speed = 300
@export var explosion_radius = 20
@export var damage = 25
@export var damage_type = "explosive"
@export var hop_distance = 90

var target: Node2D = null
var target_positioning: Vector2
var fixed_target = null
var keeps_bouncing = false
var lifetime = 6.0
var age = 0.0
var bounce_dir = Vector2.RIGHT

func _ready():
	if fixed_target != null:
		target_positioning = fixed_target
	elif is_instance_valid(target):
		target_positioning = target.global_position
	else:
		target_positioning = global_position

	var d = target_positioning - global_position
	if d.length() > 1.0:
		bounce_dir = d.normalized()

func _process(delta: float) -> void:
	age += delta
	if keeps_bouncing and age >= lifetime:
		queue_free()
		return
	
	global_position = global_position.move_toward(target_positioning, speed * delta)
	
	if global_position.distance_to(target_positioning) < 0.5:
		explode()

func explode():
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var circle = CircleShape2D.new()
	circle.radius = explosion_radius
	query.shape = circle
	query.transform = Transform2D(0, global_position)
	query.collision_mask = 2
	
	for result in space_state.intersect_shape(query):
		var body = result.collider
		if body.is_in_group("enemies") and body.has_method("take_damage"):
			body.take_damage(damage, damage_type)
		
	if keeps_bouncing:
		bounce()
	else:
		queue_free()

func bounce():
	var bounds = get_worlds_bounds()
	var next = global_position + bounce_dir * hop_distance
	
	if next.x < bounds.position.x or next.x > bounds.end.x:
		bounce_dir.x = -bounce_dir.x
	if next.y < bounds.position.y or next.y > bounds.end.y:
		bounce_dir.y = -bounce_dir.y
	
	next = global_position + bounce_dir * hop_distance
	target_positioning = next.clamp(bounds.position, bounds.end)

func get_worlds_bounds():
	var inv = get_viewport().get_canvas_transform().affine_inverse()
	return inv * get_viewport_rect()
	
	
	
	
	
