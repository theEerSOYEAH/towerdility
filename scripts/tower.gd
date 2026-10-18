extends StaticBody2D


@export var base_cost = 0
@export var bullet_scene : PackedScene
@export var fire_rate : float = 1.0
@export var can_see_camo = false
@export var damage_type = "sharp"
@onready var range_area: Area2D = $RangeArea
@export var follow_mouse = false 
@onready var sprite: Sprite2D = $Sprite2D
@onready var click_area = $ClickArea

var damange_bonus = 0
var damage_level = 0
var speed_level = 0
var range_level = 0
var total_spent = 0

const MAX_LEVEL = 3
const UPGRADE_COST = [1, 1, 1]

var enemies_in_range : Array = []
@onready var fire_timer : Timer = $FireTimer



func _process(delta: float) -> void:
	if follow_mouse:
		var angle = (get_global_mouse_position() - global_position).angle()
		sprite.rotation = angle
		sprite.flip_v = abs(angle)
	

var selected = false

func _draw():
	if selected:
		var shape = range_area.get_node("CollisionShape2D").shape
		var r = shape.radius * range_area.scale.x
		draw_circle(Vector2.ZERO, r, Color(1,1,1, 0.15))
		draw_arc(Vector2.ZERO, r, 0, TAU, 64, Color(1,1,1, 0.6), 1.0)

func set_selected(value):
	selected = value
	queue_redraw()

func _ready() -> void:
	click_area.input_event.connect(_on_click_area_input_event)
	
	total_spent = base_cost
	
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
	bullet.damage += damange_bonus
	
	get_tree().root.add_child(bullet)

func shoot_at_mouse():
	if not bullet_scene:
		return
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = (get_global_mouse_position() - global_position).normalized().rotated(randf_range(-0.06, 0.06))

	
	get_tree().root.add_child(bullet)
	
func _on_click_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("clicked")
		var panel = get_tree().get_first_node_in_group("upgrade_panel")
		print("panel is: ", panel)
		if panel:
			panel.show_for(self)

func get_cost(level):
	if level >= MAX_LEVEL:
		return -1
	return UPGRADE_COST[level]

func upgrade_damage():
	var cost = get_cost(damage_level)
	if cost == -1 or not GameManager.spend_smiles(cost):
		return
	damage_level += 1
	damange_bonus += 1
	total_spent += cost

func upgrade_speed():
	var cost = get_cost(speed_level)
	if cost == -1 or not GameManager.spend_smiles(cost):
		return
	speed_level += 1
	fire_timer.wait_time *= 0.8
	total_spent += cost

func upgrade_range():
	var cost = get_cost(range_level)
	if cost == -1 or not GameManager.spend_smiles(cost):
		return
	range_level += 1
	range_area.scale *= 1.2
	total_spent += cost

func sell():
	GameManager.add_smiles(int(total_spent * 0.5))
	queue_free()
