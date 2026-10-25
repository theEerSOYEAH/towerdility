extends StaticBody2D

@export var base_cost = 0
@export var radius = 120.0
@export var speed_bonus = 0.15
@export var damage_bonus = 0

var selected = false
var damage_level = 0
var speed_level = 0
var range_level = 0
var total_spent = 0

const MAX_LEVEL = 3
const UPGRADE_COST = [20, 20, 20]

var buffed: Array = []

@onready var clicker_area = $ClickArea

func _ready() -> void:
	total_spent = base_cost
	clicker_area.input_event.connect(_on_click_area_input_event)
	var t =Timer.new()
	t.wait_time = 0.25
	t.autostart = true
	t.timeout.connect(apply_buffs)
	add_child(t)

func apply_buffs():
	var now_in_range : Array = []
	for t in get_tree().get_nodes_in_group("towers"):
		if not is_instance_valid(t):
			continue
		if global_position.distance_to(t.global_position) <= radius:
			t.set_buff(get_instance_id(), 1.0 + speed_bonus, damage_bonus)
			now_in_range.append(t)
	for t in buffed:
		if is_instance_valid(t) and not now_in_range.has(t):
			t.clear_buff(get_instance_id())
	buffed = now_in_range

func _exit_tree() -> void:
	for t in buffed:
		if is_instance_valid(t):
			t.clear_buff(get_instance_id())

func _draw():
	if selected:
		draw_circle(Vector2.ZERO, radius, Color(0.4, 1, 0.5, 0.6))
		draw_arc(Vector2.ZERO, radius, 0, TAU, 64, Color(0.4, 1, 0.5, 0.6), 1.0)

func set_selected(value):
	selected = value
	if value:
		add_to_group("selected_towers")
	else:
		remove_from_group("selected_towers")
	queue_redraw()

func _on_click_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var panel = get_tree().get_first_node_in_group("upgrade_panel")
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
	damage_bonus += 1
	total_spent += cost

func upgrade_speed():
	var cost = get_cost(speed_level)
	if cost == -1 or not GameManager.spend_smiles(cost):
		return
	speed_level += 1
	speed_bonus += 0.1
	total_spent += cost

func upgrade_range():
	var cost = get_cost(range_level)
	if cost == -1 or not GameManager.spend_smiles(cost):
		return
	range_level += 1
	radius *= 1.2
	total_spent += cost
	queue_redraw()

func sell():
	GameManager.add_smiles(int(total_spent * 0.5))
	queue_free()
