extends StaticBody2D

@export var fire_rate: float = 2.5
@export var damage: int = 5
@export var can_see_camo = true
@export var damage_type = "sharp"
@onready var click_area = $ClickArea
@onready var fire_timer: Timer = $FireTimer

var damage_bonus = 0
var damage_level = 0
var speed_level = 0
var metal_unlocked = false
@export var metal_cost = 1

const MAX_LEVEL = 3
const UPGRADE_COST = [100, 200, 300]

func _ready() -> void:
	click_area.input_event.connect(_on_click_area_input_event)
	
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = false
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	fire_timer.start()
	
func _on_fire_timer_timeout() -> void:
	var target = get_first_enemy()
	if target:
		shoot(target)
		

func get_first_enemy() -> Node2D:
	var best = null
	var best_progress := -1.0
	for e in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e):
			continue
		if e.is_camo and not can_see_camo:
			continue
			
		var pf = e.get_parent()
		if pf is PathFollow2D and pf.progress > best_progress:
			best_progress = pf.progress
			best = e
	return best

func shoot(target: Node2D) -> void:
	var hit_pos := target.global_position
	target.take_damage(damage + damage_bonus, damage_type)
	draw_tracer(hit_pos)

func draw_tracer(to_pos: Vector2) -> void:
	var line = Line2D.new()
	line.width = 1.5
	line.default_color = Color.WHITE
	line.points = [Vector2.ZERO, to_local(to_pos)]
	add_child(line)
	
	var tween := create_tween()
	tween.tween_property(line, "modulate:a", 0.0, 0.15)
	tween.tween_callback(line.queue_free)

func _on_click_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var panel = get_tree().get_first_node_in_group("sniper_upgrade_panel")
		if panel:
			panel.show_for(self)

func set_selected(value):
	pass

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

func upgrade_speed():
	var cost = get_cost(speed_level)
	if cost == -1 or not GameManager.spend_smiles(cost):
		return
	speed_level += 1
	fire_timer.wait_time *= 0.8

func upgrade_metal():
	if metal_unlocked:
		return
	if not GameManager.spend_smiles(metal_cost):
		return
	metal_unlocked = true
	damage_type = "piercing"
	
