extends StaticBody2D

var slots = [Vector2(-20, 10), Vector2(15, -5), Vector2(+25, +10), Vector2(-10, 20)]

@export var smilles_per_tick = 1
@export var interval : float= 1.0

var farmer_scale = Vector2.ONE

@export var base_cost : int = 0
var damage_level = 0
var speed_level = 0
var range_level = 0
var total_spent = 0
var timer: Timer
const MAX_LEVEL = 3
const UPGRADE_COST = [20, 20, 20]

@export var farmer_cost = 50
@export var farmer_range = 80
var has_farmer = false
var selected = false
@onready var click_area: Area2D = $ClickArea
@onready var farmer: AnimatedSprite2D = $farmer

@export var pick_up_scene: PackedScene
@export var max_pickups = 5
var pickups: Array = []

func _ready() -> void:
	
	timer = Timer.new()
	timer.wait_time = interval
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	total_spent = base_cost
	
	farmer_scale = farmer.scale
	farmer.visible = false
	click_area.input_event.connect(_on_click_area_input_event)

func _on_timer_timeout():
	var s = get_tree().get_first_node_in_group("spawner")
	var running = s != null and (s.wave_running or get_tree().get_nodes_in_group("enemies").size() > 0)
	if not running:
		return
	
	
	pickups = pickups.filter(func(p): return is_instance_valid(p))
	if pickups.size() >= max_pickups:
		return
	
	var used = pickups.map(func(x): return x.get_meta("slot", -1))
	var slot = 0
	while slot in used:
		slot += 1
	
	var p = pick_up_scene.instantiate()
	p.value = smilles_per_tick
	p.set_meta("slot", slot)
	add_child(p)
	p.position = Vector2.ZERO
	pickups.append(p)
	print("slot", slot, slots[slot % slots.size()])
	
	var tw = p.create_tween()
	tw.tween_property(p, "position", slots[slot % slots.size()], 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if has_farmer:
		auto_collect(p)


func _on_click_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var panel = get_tree().get_first_node_in_group("upgrade_panel")
		if panel:
			panel.show_for(self)
		else:
			for t in get_tree().get_nodes_in_group("selected_towers"):
				t.set_selected(false)
			set_selected(true)

func set_selected(value):
	selected = value
	if value:
		add_to_group("selected_towers")
	else:
		remove_from_group("selected_towers")
	queue_redraw()


func _draw():
	if selected:
		draw_circle(Vector2.ZERO, farmer_range, Color(1, 1, 1, 0.15))
		draw_arc(Vector2.ZERO, 30, 0, TAU, 32, Color(1, 1, 1, 0.6), 1.0)



func hire_farmer():
	if has_farmer:
		return
	if not GameManager.spend_smiles(farmer_cost):
		return
	has_farmer = true
	farmer.visible = true
	farmer.scale = Vector2.ZERO
	create_tween().tween_property(farmer, "scale", farmer_scale, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	for p in pickups:
		if is_instance_valid(p):
			auto_collect(p)



func auto_collect(p):
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(p) and p.position.length() <= farmer_range:
		p.collect()

func get_cost(level):
	if level >= MAX_LEVEL:
		return -1
	return UPGRADE_COST[level]

func upgrade_damage():
	var cost = get_cost(damage_level)
	if cost == -1 or not GameManager.spend_smiles(cost):
		return
	damage_level += 1
	smilles_per_tick += 1
	total_spent = cost
	


func upgrade_speed():
	var cost = get_cost(speed_level)
	if cost == -1 or not GameManager.spend_smiles(cost):
		return
	speed_level += 1
	interval *= 0.8
	timer.wait_time = interval
	total_spent += cost


func upgrade_range():
	var cost = get_cost(range_level)
	if cost == -1 or not GameManager.spend_smiles(cost):
		return
	range_level += 1
	farmer_range += 1.3
	total_spent += cost


func sell():
	GameManager.add_smiles(int(total_spent * 0.5))
	queue_free()
