extends Area2D


@export var speed = 500
@export var damage = 1
@export var max_distance = 300
@export var rotation_offest_degrees = 0

var damage_type = "sharp"
var direction = Vector2.ZERO
var travelled = 0.0

func _ready():
	body_entered.connect(_on_body_entered)
	face_direction()

func face_direction():
	if direction.length() > 0.01:
		rotation = direction.angle() + deg_to_rad(rotation_offest_degrees)


func _physics_process(delta):
	var step = direction * speed * delta
	global_position += step
	travelled += step.length()
	
	
	if travelled >= max_distance:
		queue_free()
		
func _on_body_entered(body) -> void:
	if not body.is_in_group("enemies"):
		return
	body.take_damage(damage, damage_type)
	queue_free()
