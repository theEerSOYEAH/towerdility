extends StaticBody2D

@export var dart_scene: PackedScene
@export var fire_rate: float = 1.2
@export var damage_type = "sharp"
@export var can_see_camo = false
@export var base_cost = 0
@export var darts_per_volley = 12
@export var dart_spread = 1.0
@export var flight_speed = 1.6
@export var metal_cost = 150

@onready var plane = $Plane
@onready var range_area = $RangeArea
@onready var click_area = $ClickArea
@onready var fire_timer = $FireTimer
@onready var sprite = $Plane/AnimatedSprite2D

var range_radius = 0.0
var orbit_radius = 0.0
var orbit_angle = 0.0

var damage_bonus = 0
var damage_level = 0
var speed_level = 0
var metal_unlocked = false
var total_spent = 0
var selected = false
var tower_title = "Ace"

var sprite_scale = Vector2.ONE
var hover_tween: Tween

var tracking_level = 0
const TRACKING_POWER = [0.0, 1.5, 3.0, 5.0]

const MAX_LEVEL = 3
const UPGRADE_COST = [50, 100, 200]

func _ready():
	add_to_group("towers")
	total_spent = base_cost
	
	var shape = range_area.get_node("CollisionShape2D").shape
	range_radius = shape.radius * range_area.scale.x
	orbit_radius = range_radius * 0.6
	orbit_angle = randf() * TAU
	
	click_area.input_event.connect(_on_click_area_input_event)
	click_area.mouse_entered.connect(_on_hover.bind(true))
	click_area.mouse_exited.connect(_on_hover.bind(false))
	
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = false
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	fire_timer.start()
	
	sprite_scale = sprite.scale
	play_place_animation()


func _process(delta):
	orbit_angle += flight_speed * delta
	plane.position = Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
	plane.rotation = orbit_angle + PI / 2

func _on_fire_timer_timeout():
	var target = get_nearest_enemy()
	if target == null:
		return
	shoot_volley(target)
	
func get_nearest_enemy():
	var best = null
	var best_dist = INF
	for e in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e):
			continue
		if e.is_camo and not can_see_camo:
			continue
		if e.global_position.distance_to(global_position) > range_radius:
			continue
		var d = e.global_position.distance_to(plane.global_position)
		if d < best_dist:
			best_dist = d
			best = e
	return best

func shoot_volley(target):
	if not dart_scene:
		print("no dart scne on thr aceee")
		return
	
	var base_dir = Vector2.RIGHT.rotated(plane.rotation)
	
	for i in darts_per_volley:
		var offset = 0.0
		if darts_per_volley > 1:
			offset = lerp(-dart_spread, dart_spread, float(i) / (darts_per_volley - 1))
		
		var dart = dart_scene.instantiate()
		dart.global_position = plane.global_position
		dart.direction = base_dir.rotated(offset)
		dart.damage_type = damage_type
		dart.damage += damage_bonus
		dart.tracking = TRACKING_POWER[tracking_level]
		dart.can_see_camo = can_see_camo
		if "max_distance" in dart:
			dart.max_distance = range_radius + 80
		get_tree().current_scene.add_child(dart)


func _on_click_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var panel = get_tree().get_first_node_in_group("ace_upgrade_panel")
		if panel:
			panel.show_for(self)

func _draw():
	if selected:
		draw_circle(Vector2.ZERO, range_radius, Color(1, 1, 1, 0.15))
		draw_arc(Vector2.ZERO, range_radius, 0, TAU, 64, Color(1, 1, 1, 0.6), 1.0)

func set_selected(value):
	selected = value
	queue_redraw()


func get_cost(level):
	if level >= MAX_LEVEL:
		return -1
	return UPGRADE_COST[level]
	
func upgrade_damage():
	var cost = get_cost(damage_level)
	if cost == -1 or not GameManager.spend_smiles(cost):
		return
	damage_level += 1
	damage_bonus += 1
	total_spent += cost

func upgrade_speed():
	var cost = get_cost(speed_level)
	if cost == -1 or not GameManager.spend_smiles(cost):
		return
	speed_level += 1
	fire_timer.wait_time *= 0.8
	total_spent += cost

func upgrade_metal():
	if metal_unlocked:
		return
	if not GameManager.spend_smiles(metal_cost):
		return
	metal_unlocked = true
	damage_type = "piercing"
	total_spent += metal_cost

func upgrade_tracking():
	var cost = get_cost(tracking_level)
	if cost == -1 or not GameManager.spend_smiles(cost):
		return
	tracking_level += 1
	total_spent += cost

func sell():
	GameManager.add_smiles(int(total_spent * 0.5))
	queue_free()

func play_place_animation():
	sprite.scale = sprite_scale * 0.3
	var tw = create_tween() 
	tw.tween_property(sprite, "scale", sprite_scale, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_hover(is_hovering):
	if hover_tween:
		hover_tween.kill()
	hover_tween = create_tween().set_parallel(true)
	
	var target_scale = sprite_scale
	var target_color = Color.WHITE
	if is_hovering:
		target_scale = sprite_scale * 1.15
		target_color = Color(1.3, 1.3, 1.3)
	hover_tween.tween_property(sprite, "scale", target_scale, 0.1)
	hover_tween.tween_property(sprite, "modulate", target_color, 0.1)

func get_save_data():
	return {
		"damage_level": damage_level,
		"speed_level": speed_level,
		"damage_bonus": damage_bonus,
		"metal_unlocked": metal_unlocked,
		"total_spent": total_spent,
		"tracking_level": tracking_level
	}

func apply_save_data(d):
	damage_level = int(d.get("damage_level", 0))
	speed_level = int(d.get("speed_level", 0))
	tracking_level = int(d.get("tracking_level", 0))
	damage_bonus = int(d.get("damage_bonus", 0))
	total_spent = int(d.get("total_spent", base_cost))
	fire_timer.wait_time = fire_rate * pow(0.8, speed_level)
	metal_unlocked = bool(d.get("metal_unlocked", false))
	if metal_unlocked:
		damage_type = "piercing"
	
