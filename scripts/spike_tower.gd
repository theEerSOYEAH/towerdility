extends StaticBody2D

@export var spike_scene: PackedScene
@export var fire_rate = 3.0
@export var base_cost = 0
@export var damage_type = "sharp"
@export var metal_cost = 0

var metal_unlocked = false
var tower_title = "Spikes"

@onready var range_area = $RangeArea
@onready var click_area = $ClickArea
@onready var fire_timer = $FireTimer
@onready var sprite = $Sprite2D
var spike_radius = 0.0
var sprite_scale = Vector2.ONE
var hover_tween: Tween

var damage_bonus = 0
var damage_level = 0
var speed_level = 0
var range_level = 0
var total_spent = 0
var selected = false

const MAX_LEVEL = 3
const UPGRADE_COST = [1, 1, 1]

func _ready() -> void:
	var shape = range_area.get_node("CollisionShape2D").shape
	spike_radius = shape.radius * range_area.scale.x
	total_spent = base_cost
	click_area.input_event.connect(_on_click_area_input_event)
	
	sprite_scale = sprite.scale
	click_area.mouse_entered.connect(_on_hover.bind(true))
	click_area.mouse_exited.connect(_on_hover.bind(false))
	play_place_animation
	
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = false
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	fire_timer.start()
	
func _on_fire_timer_timeout():
	var pos = get_random_path_point()
	if pos == null:
		return
	var spike = spike_scene.instantiate()
	spike.global_position = pos
	spike.damage += damage_bonus
	spike.damage_type = damage_type
	get_tree().root.add_child(spike)
	
func get_random_path_point():
	var path = get_tree().get_first_node_in_group("path")
	if path == null:
		print("no node in group 'path' ")
		return null
	
	var length = path.curve.get_baked_length()
	for i in 30:
		var p = path.to_global(path.curve.sample_baked(randf() * length))
		if p.distance_to(global_position) <= spike_radius:
			return p 
	return null

func _on_click_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var panel = get_tree().get_first_node_in_group("sniper_upgrade_panel")
		if panel:
			panel.show_for(self)
		
func _draw() -> void:
	if selected:
		draw_circle(Vector2.ZERO, spike_radius, Color(1, 1, 1, 0.15))
		draw_arc(Vector2.ZERO, spike_radius, 0, TAU, 64, Color(1, 1, 1, 0.6), 1.0)

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

func upgrade_range():
	var cost = get_cost(range_level)
	if cost == -1 or not GameManager.spend_smiles(cost):
		return
	range_level += 1
	range_area.scale *= 1.2
	spike_radius *= 1.2
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
	
func upgrade_metal():
	if metal_unlocked:
		return
	if not GameManager.spend_smiles(metal_cost):
		return
	metal_unlocked = true
	damage_type = "piercing"
	total_spent += metal_cost
