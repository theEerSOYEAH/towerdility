extends StaticBody2D

@export var fire_rate: float = 2.5
@export var damage: int = 5
@export var can_see_camo = true
@export var damage_type = "sharp"
@export var base_cost = 0
@onready var click_area = $ClickArea
@onready var fire_timer: Timer = $FireTimer
@onready var sprite = $Sprite2D

var damage_bonus = 0
var damage_level = 0
var speed_level = 0
var total_spent = 0
var metal_unlocked = false
@export var metal_cost = 1

const MAX_LEVEL = 3
const UPGRADE_COST = [100, 200, 300]

var sprite_scale = Vector2.ONE
var hover_tween: Tween


func _ready() -> void:
	click_area.input_event.connect(_on_click_area_input_event)
	total_spent = base_cost

	# find the sprite even if it isn't named "Sprite2D"
	if sprite == null:
		for c in get_children():
			if c is Sprite2D or c is AnimatedSprite2D:
				sprite = c
				break

	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = false
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	fire_timer.start()

	sprite_scale = sprite.scale
	click_area.mouse_entered.connect(_on_hover.bind(true))
	click_area.mouse_exited.connect(_on_hover.bind(false))
	play_place_animation()
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
