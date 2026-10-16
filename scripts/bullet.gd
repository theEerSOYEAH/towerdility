extends Area2D

@export var speed = 400
@export var damage = 2
var target : Node2D = null
var last_position : Vector2

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if is_instance_valid(target):
		last_position = target.global_position

func _physics_process(delta: float) -> void:
	if is_instance_valid(target):
		last_position = target.global_position
	
	var direction = (last_position - global_position).normalized()
	global_position += direction * speed * delta
	
	if global_position.distance_to(last_position) < 5:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	print("enteredbullet1")
	if body == target:
		body.take_damage(damage)
		queue_free()
		
