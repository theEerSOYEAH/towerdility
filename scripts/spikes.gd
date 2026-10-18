extends Area2D

@export var damage = 1
@export var pierce = 6
@export var lifetime = 12.0
var damage_type = "sharp"

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _on_body_entered(body):
	print("spike touched", body.name)
	if not body.is_in_group("enemies"):
		return
	
	if body.is_metal and damage_type == "sharp":
		return
	
	body.take_damage(damage, damage_type)
	pierce -= 1
	if pierce <= 0:
		queue_free()

func _draw() -> void: # Temp Since there is no art
	for i in 3:
		var x = -5 + i * 5
		draw_colored_polygon(PackedVector2Array([Vector2(x - 2.5, 3), Vector2(x, -4), Vector2(x + 2.5, 3)]), Color(0.75, 0.75, 0.8))
