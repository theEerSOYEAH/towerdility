extends Area2D


@export var speed = 500
@export var damage = 1
@export var max_distance = 300

var direction = Vector2.ZERO
var travelled = 0.0

func _ready():
	body_entered.connect(_on_body_entered)
	rotation = direction.angle()
	
func _physics_process(delta):
	var step = direction * speed * delta
	global_position += step
	travelled = step.length()
	
	if travelled >= max_distance:
		queue_free()
		
func _on_body_entered(body) -> void:
	if not body.is_in_group("enemies"):
		return
	body.take_damage(damage)
	queue_free()
