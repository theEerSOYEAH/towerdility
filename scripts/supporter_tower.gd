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
		if global_position.direction_to(t.global_position) <= radius:
			t.set_buff(get_instance_id(),1,0 + speed_bonus, damage_bonus)
			now_in_range.append(t)
	for t in buffed:
		if is_instance_valid(t) and not now_in_range.has(t):
			t.clear_buff(get_instance_id())
		buffed = now_in_range
