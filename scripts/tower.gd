extends StaticBody2D


@export var bullet_scene : PackedScene
@export var fire_rate : float = 1.0
@export var can_see_camo = false
@export var damage_type = "sharp"
@onready var range_area: Area2D = $RangeArea
@export var follow_mouse = false 
@onready var sprite: Sprite2D = $Sprite2D


var enemies_in_range : Array = []
@onready var fire_timer : Timer = $FireTimer



func _process(delta: float) -> void:
	if follow_mouse:
		var angle = (get_global_mouse_position() - global_position).angle()
		sprite.rotation = angle
		sprite.flip_v = abs(angle)
	


func _ready() -> void:
	
	if range_area:
		if range_area.body_entered.is_connected(_on_range_area_body_entered):
			range_area.body_entered.disconnect(_on_range_area_body_entered)
		if range_area.body_exited.is_connected(_on_range_area_body_exited):
			range_area.body_exited.disconnect(_on_range_area_body_exited)
		
		range_area.body_entered.connect(_on_range_area_body_entered)
		range_area.body_exited.connect(_on_range_area_body_exited)

	
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = false
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	fire_timer.start()





func _on_range_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if body.is_camo and not can_see_camo:
			return
		enemies_in_range.append(body)
		print("12341")

func _on_range_area_body_exited(body: Node2D) -> void:
	if body in enemies_in_range:
		enemies_in_range.erase(body)


func _on_fire_timer_timeout() -> void:
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))
	
	if enemies_in_range.size() > 0:
		if follow_mouse:
			shoot_at_mouse()
		else:
			shoot(enemies_in_range[0])

func shoot(target: Node2D):
	if not bullet_scene:
		print("nobulletscene")
		return
	
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.target = target
	bullet.damage_type = damage_type
	
	get_tree().root.add_child(bullet)

func shoot_at_mouse():
	if not bullet_scene:
		return
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = (get_global_mouse_position() - global_position).normalized().rotated(randf_range(-0.06, 0.06))

	
	get_tree().root.add_child(bullet)
	
