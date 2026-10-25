extends StaticBody2D

var buffs : Dictionary = {}

@export var panel_group = "upgrade_panel"

enum TargetMode {FIRST, LAST, STRONGEST, WEAKEST}
const MODE_NAMES =["First", "Last", "Strongest", "Weakist"]
var target_mode = TargetMode.FIRST
@export var flip_when_left = true
@export var turn_speed: float = 12.0
var aim_angle = 0.0
var selected = false
@export var base_cost : int = 0
@export var bullet_scene : PackedScene
@export var fire_rate : float = 1.0
@export var max_bombs = 3
var active_bombs = []
@export var is_bomber = false
var bounce_level = 0
@export var can_see_camo = false
@export var damage_type = "sharp"
@onready var range_area: Area2D = $RangeArea
@export var follow_mouse = false 
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var sprite_offset_degrees = 0.0
@export var rotate_to_enemy = false
@export var is_necromancer = false
@export var minion_scene : PackedScene
@export var max_minions = 3
@export var minion_lifetime = 12
var minions : Array = []

@export var multishot_capable = false
@export var multishot_cost = 60
@export var multishot_extra = 2
var multishot_unlocked = false

@export var minion_leash = 120

@onready var click_area = $ClickArea

var damange_bonus = 0
var damage_level = 0
var speed_level = 0
var range_level = 0
var total_spent = 0

var locked = false
var awaiting_lock = false
var locked_position = Vector2.ZERO

const MAX_LEVEL = 3
const UPGRADE_COST = [20, 20, 20]

var enemies_in_range : Array = []
@onready var fire_timer : Timer = $FireTimer


func on_enemy_killed(pos: Vector2):
	if not is_necromancer:
		return
	spawn_minion(get_path_end())

func get_path_end() -> Vector2:
	var p = get_tree().get_first_node_in_group("enemy_path")
	if p == null or p.curve == null or p.curve.point_count == 0:
		print("noenemypathfound")
		return global_position
	return p.to_global(p.curve.get_point_position(p.curve.point_count - 1))

func spawn_minion(pos: Vector2):
		if not minion_scene:
			return
		minions = minions.filter(func(m): return is_instance_valid(m))
		if minions.size() >= max_minions:
			return
		var m = minion_scene.instantiate()
		m.home = pos
		m.damage = 1 + damange_bonus + get_buff_damage()
		m.damage_type = damage_type
		m.can_see_camo = can_see_camo
		m.lifetime = minion_lifetime
		m.leash = range_area.get_node("CollisionShape2D").shape.radius * range_area.scale.x
		get_tree().root.add_child(m)
		m.global_position = pos
		minions.append(m)

func _exit_tree() -> void:
	for m in minions:
		if is_instance_valid(m):
			m.queue_free()


func set_buff(source_id: int, speed_mult: float, damage_add: int):
	var new_buff = {"speed": speed_mult, "damage": damage_add}
	if buffs.get(source_id) == new_buff:
		return
	buffs[source_id] = new_buff
	refresh_fire_rate()
	print(name, "buffed: wait_time=", fire_timer.wait_time, "damage_bonus=", get_buff_damage())




func clear_buff(source_id: int):
	if buffs.erase(source_id):
		refresh_fire_rate()
		print(name, "buff removed wait_time=", fire_timer.wait_time)

func get_buff_speed():
	var best := 1.0
	for b in buffs.values():
		best = max(best, b["speed"])
	return best

func get_buff_damage():
	var best := 0
	for b in buffs.values():
		best = max(best, b["damage"])
	return best



func refresh_fire_rate():
	fire_timer.wait_time = fire_rate * pow(0.8, speed_level)/ get_buff_speed()

func cycle_target_mode():
	target_mode = (target_mode + 1) % MODE_NAMES.size()

func get_target_mode_name():
	return MODE_NAMES[target_mode]

func get_progress(e: Node2D):
	if not is_instance_valid(e):
		return 0.0
	var pf = e.get_parent()
	if pf is PathFollow2D:
		return float(pf.progress)
	return 0.0

func get_health(e: Node2D) -> float:
	var hp = e.get("current_health")
	return float(hp) if hp != null else 0.0

func get_score(e: Node2D) -> float:
	match target_mode:
		TargetMode.FIRST:
			return get_progress(e)
		TargetMode.LAST:
			return -get_progress(e)
		TargetMode.STRONGEST:
			return get_health(e) + get_progress(e) * 0.0001
		TargetMode.WEAKEST:
			return -get_health(e) + get_progress(e) * 0.0001
	return 0.0

func get_targets(count: int) -> Array:
	var canditates: Array
	if target_mode == TargetMode.LAST:
		canditates = get_tree().get_nodes_in_group("enemies").filter(
			func (e): return is_instance_valid(e) and (can_see_camo or not e.is_camo)
		)
	else:
		enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))
		canditates = enemies_in_range
	
	var scored: Array = []
	for e in canditates:
		scored.append({"e": e, "s": get_score(e)})
	scored.sort_custom(func(a, b):return a["s"] > b["s"])
	
	var result: Array = []
	for i in min(count, scored.size()):
		result.append(scored[i]["e"])
	return result

func get_target():
	var t = get_targets(1)
	return t[0] if t.size() > 0 else null
	
	

func play_throw_anim():
	if not sprite.sprite_frames or not sprite.sprite_frames.has_animation("empty"):
		return
	sprite.play("empty")
	await get_tree().create_timer(fire_timer.wait_time * 0.8).timeout
	if is_inside_tree():
		sprite.play("holding")

func _process(delta: float) -> void:
	if follow_mouse:
		var angle = (get_aim_position() - global_position).angle()
		sprite.rotation = angle
		sprite.flip_v = abs(angle) > PI / 2
	elif rotate_to_enemy:
		aim_at_enemy()
		var goal = aim_angle + deg_to_rad(sprite_offset_degrees)
		sprite.rotation = lerp_angle(sprite.rotation, goal, 1.0 - exp(-turn_speed * delta))
		update_flip()




func face(target_pos: Vector2, snap:= false):
	aim_angle = (target_pos - global_position).angle()
	if snap:
		sprite.rotation = aim_angle + deg_to_rad(sprite_offset_degrees)
		update_flip()

func update_flip():
	if not flip_when_left:
		return
	var a = wrapf(sprite.rotation - deg_to_rad(sprite_offset_degrees), -PI, PI)
	sprite.flip_v = abs(a) > PI / 2




func aim_at_enemy():
	
	var t = get_target()
	if t:
		face(t.global_position)



func _draw():
	if selected:
		var shape = range_area.get_node("CollisionShape2D").shape
		var r = shape.radius * range_area.scale.x
		draw_circle(Vector2.ZERO, r, Color(1, 1, 1, 0.15))
		draw_arc(Vector2.ZERO, r, 0, TAU, 64, Color(1, 1, 1, 0.6), 1.0)

	if locked:
		var p = to_local(locked_position)
		draw_line(p + Vector2(-6, 0), p + Vector2(6, 0), Color.RED, 1.5)
		draw_line(p + Vector2(0, -6), p + Vector2(0, 6), Color.RED, 1.5)
		draw_arc(p, 5, 0, TAU, 16, Color.RED, 1.5)
	
	
	
	
func set_selected(value):
	selected = value
	if value:
		add_to_group("selected_towers")
	else:
		remove_from_group("selected_towers")
	queue_redraw()

func _ready() -> void:
	add_to_group("towers")
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


func start_locking():
	if not can_lock():
		return
	awaiting_lock = true

func unlock():
	locked = false
	awaiting_lock = false
	queue_redraw()

func get_aim_position():
	if locked:
		return locked_position
	return get_global_mouse_position()

func _unhandled_input(event) -> void:
	if not awaiting_lock:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			locked_position = get_global_mouse_position()
			locked = true
			awaiting_lock = false
			get_viewport().set_input_as_handled()
			queue_redraw()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			awaiting_lock = false
			get_viewport().set_input_as_handled()
			
		


func _on_range_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if body.is_camo and not can_see_camo:
			return
		enemies_in_range.append(body)
		print("12341")

func _on_range_area_body_exited(body: Node2D) -> void:
	if body in enemies_in_range:
		enemies_in_range.erase(body)

func get_shot_count() -> int:
	return 1 + (multishot_extra if multishot_unlocked else 0)

func _on_fire_timer_timeout() -> void:
	if follow_mouse:
		enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))
		if enemies_in_range.size() > 0:
			shoot_at_mouse()
		return
	
	var shots = get_shot_count()
	var targets = get_targets(shots)
	if targets.is_empty():
		return
	
	for i in shots:
		var t = targets[i % targets.size()]
		if is_instance_valid(t):
			shoot(t, i, shots)

const MULTISHOT_SPACING = 14.0

func shoot(target: Node2D, index := 0, total := 1):
	if not bullet_scene:
		print("no bullet scene")
		return
	
	if is_bomber and bounce_level > 0:
		active_bombs = active_bombs.filter(func(b): return is_instance_valid(b))
		if active_bombs.size() >= max_bombs:
			return
		
	
	if rotate_to_enemy:
		face(target.global_position, true)
	
	var bullet = bullet_scene.instantiate()
	
	if "max_distance" in bullet:
		var dist = global_position.distance_to(target.global_position)
		bullet.max_distance = max(bullet.max_distance, dist + 100)
	
	var dir = (target.global_position - global_position).normalized()
	var side = dir.orthogonal()
	var offset = (index - (total - 1) / 2.0) * MULTISHOT_SPACING
	bullet.global_position = global_position + side * offset
	
	bullet.damage_type = damage_type
	if "source_tower" in bullet:
		bullet.source_tower = self
	bullet.damage += damange_bonus + get_buff_damage()
	
	if "target" in bullet:
		bullet.target = target
	else:
		bullet.direction = dir
	
	if is_bomber:
		bullet.keeps_bouncing = bounce_level > 0
		bullet.lifetime = 4.0 + bounce_level * 2.0
		if locked:
			bullet.fixed_target = locked_position
		active_bombs.append(bullet)
	
	get_tree().root.add_child(bullet)
	play_throw_anim()
	

func shoot_at_mouse():
	if not bullet_scene:
		return

	var aim = get_aim_position()
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = (aim - global_position).normalized().rotated(randf_range(-0.06, 0.06))
	bullet.damage_type = damage_type
	bullet.damage += damange_bonus + get_buff_speed()

	get_tree().root.add_child(bullet)

func _on_click_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("clicked")
		if follow_mouse or is_bomber:
			for t in get_tree().get_nodes_in_group("lock_target"):
				t.remove_from_group("lock_target")
			add_to_group("lock_target")
		var panel = get_tree().get_first_node_in_group(panel_group)
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
	refresh_fire_rate()
	total_spent += cost

func upgrade_range():
	var cost = get_cost(range_level)
	if cost == -1 or not GameManager.spend_smiles(cost):
		return
	range_level += 1
	range_area.scale *= 1.2
	total_spent += cost

func upgrade_multishot():
	if not multishot_capable or multishot_unlocked:
		return
	if not GameManager.spend_smiles(multishot_cost):
		return
	multishot_unlocked = true
	total_spent += multishot_cost

func upgrade_bounce():
	var cost = get_cost(bounce_level)
	if cost == -1 or not GameManager.spend_smiles(cost):
		return
	bounce_level += 1
	total_spent += cost
	
func sell():
	GameManager.add_smiles(int(total_spent * 0.5))
	queue_free()

func get_save_data():
	return {
		"damage_level": damage_level,
		"speed_level": speed_level,
		"range_level": range_level,
		"multishot": multishot_unlocked,
		"bounce_level": bounce_level,
		"damage_bonus": damange_bonus,
		"total_spent": total_spent,
		"range_scale": range_area.scale.x,
		"target_mode": target_mode,
		"locked": locked,
		"locked_x": locked_position.x,
		"locked_y": locked_position.y,
	}

func apply_save_data(d):
	damage_level = int(d.get("damage_level", 0))
	speed_level = int(d.get("speed_level", 0))
	range_level = int(d.get("range_level", 0))
	damange_bonus = int(d.get("damage_bonus", 0))
	bounce_level = int(d.get("bounce_level", 0))
	total_spent = int(d.get("total_spent", base_cost))
	multishot_unlocked = bool(d.get("multishot", false))
	target_mode = int(d.get("target_mode", 0))
	
	var s = float(d.get("range_scale", range_area.scale.x))
	range_area.scale = Vector2(s, s)
	refresh_fire_rate()
	
	locked = bool(d.get("locked", false))
	locked_position = Vector2(float(d.get("locked_x", 0)), float(d.get("locked_y", 0)))
	queue_redraw()

func can_lock():
	return follow_mouse or (is_bomber and bounce_level > 0)
