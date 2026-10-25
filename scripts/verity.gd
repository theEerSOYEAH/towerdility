extends CharacterBody2D

var next_path : Path2D = null
var path_offset = 0.0

@export var speed = 40
@export var max_health = 10
@export var reward = 10
@export var is_metal = false
@export var is_camo = false
@export var label_offset = Vector2(-10, -30)

@onready var health_label: Label = $Label


@export var minion_damage = 1
var blocked = false

var slow_factor :float = 1.0
var slow_time :float = 0.0

var last_source = null

var current_health  : int
var is_dying = false
var path_follow : PathFollow2D = null

func _ready() -> void:
	current_health = max_health
	if health_label:
		health_label.top_level = true
	update_health_label()
	if get_parent() is PathFollow2D:
		path_follow = get_parent()
	
	if is_metal:
		modulate = Color(0.6, 0.7, 0.9)
	if is_camo:
		modulate.a = 0.5

func _process(delta: float) -> void:
	_update_slow(delta)
	
	if path_follow and not blocked:
		path_follow.progress += speed * slow_factor * delta
		
		if path_follow.progress_ratio >= 1.0:
			reach_base()
	if health_label:
		health_label.global_position = global_position + label_offset

func take_damage(amount, damage_type = "sharp", source = null):
	print("hit type=[", damage_type, "] metal=", is_metal, " from=", source)
	if is_dying:
		return
		
	if is_metal and damage_type.strip_edges().to_lower() == "sharp":
		return
	
	last_source = source
	current_health -= amount
	$AudioStreamPlayer2D.play()
	update_health_label()
	
	if current_health <= 0:
		die()
func apply_slow(factor : float, duration : float):
	slow_factor = factor
	slow_time = duration
	modulate = Color(0.5, 0.8, 1.0)

func _update_slow(delta: float):
	if slow_time > 0.0:
		slow_time -= delta
		if slow_time <= 0.0:
			slow_factor = 1.0
			modulate = Color(1, 1, 1)
			

func reach_base():
	print("1299990")
	if is_dying:
		return
	if next_path:
		switch_path()
		return
	is_dying = true
	GameManager.lose_health(current_health)
	path_follow.queue_free()

func die():
	is_dying = true
	GameManager.add_smiles(reward, global_position)
	if is_instance_valid(last_source) and last_source.has_method("on_enemy_killed"):
		last_source.on_enemy_killed(global_position)
	path_follow.queue_free()


func switch_path():
	var old_pf = path_follow
	path_offset += old_pf.get_parent().curve.get_baked_length()
	var np = next_path
	next_path = null
	
	var new_pf = PathFollow2D.new()
	new_pf.loop = false
	new_pf.rotates = true
	
	old_pf.remove_child(self)
	new_pf.add_child(self)
	np.add_child(new_pf)
	path_follow = new_pf
	old_pf.queue_free()

func update_health_label():
	if health_label:
		health_label.text = str(max(current_health, 0))
