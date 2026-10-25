extends StaticBody2D

var slots = [Vector2(-20, 10), Vector2(15, -5), Vector2(+25, +10), Vector2(-10, 20)]

@export var smilles_per_tick = 1
@export var interval : float= 1.0

@export var pick_up_scene: PackedScene
@export var max_pickups = 5
var pickups: Array = []

func _ready() -> void:
	
	var timer = Timer.new()
	timer.wait_time = interval
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

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
