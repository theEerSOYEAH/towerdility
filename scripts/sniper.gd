extends StaticBody2D

@export var fire_rate: float = 2.5
@export var damage: int = 5
@onready var fire_timer: Timer = $FireTimer

func _ready() -> void:
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = false
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	fire_timer.start()
	
func _on_fire_timer_timeout() -> void:
	var target = get_first_enemy()
	if target:
		shoot(target)
		

func get_first_enemy() -> Node2D:
	var best: Node2D = null
	var best_progress := -1.0
	for e in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e):
			continue
		var pf = e.get_parent()
		if pf is PathFollow2D and pf.progress > best_progress:
			best_progress = pf.progress
			best = e
	return best

func shoot(target: Node2D) -> void:
	var hit_pos := target.global_position
	target.take_damage(damage)
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
