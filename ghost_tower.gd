extends Node2D

@export var real_tower_scene : PackedScene
var is_valid_placement : bool = true
var overlaps : Array = []
var range_radius = 0.0

@onready var area_2d = $Area2D

func _ready():
	area_2d.body_entered.connect(_on_area_2d_body_entered)
	area_2d.body_exited.connect(_on_area_2d_body_exited)
	area_2d.area_entered.connect(_on_area_2d_area_entered)
	area_2d.area_exited.connect(_on_area_2d_area_exited)
	var temp = real_tower_scene.instantiate()
	var range_node = temp.get_node_or_null("RangeArea/CollisionShape2D")
	if range_node and range_node.shape is CircleShape2D:
		range_radius = range_node.shape.radius * temp.get_node("RangeArea").scale.x
	temp.queue_free()
	queue_redraw()
	
func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	
	if overlaps.size() > 0:
		is_valid_placement = false
		modulate = Color(1, 0, 0, 0.5)
	else:
		is_valid_placement = true
		modulate = Color(0, 1, 0, 0.5)
	queue_redraw()
	
	if Input.is_action_just_pressed("ui_click") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if is_valid_placement:
			place_tower()
		else:
			print("cannotplacehereLOL")
	if Input.is_action_just_pressed("ui_right_click") or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		queue_free()

func _draw():
	if range_radius > 0:
			draw_circle(Vector2.ZERO, range_radius, Color(1,1,1, 0.3))
			draw_arc(Vector2.ZERO, range_radius, 0, TAU, 64, Color(1,1,1, 0.3), 1.0)
		
		
func place_tower():
	var new_tower = real_tower_scene.instantiate()
	new_tower.global_position = global_position
	get_tree().root.add_child(new_tower)
	
	queue_free()
	



func _on_area_2d_body_entered(body: Node2D) -> void:
	print("body", body.name)
	overlaps.append(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	overlaps.erase(body)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "RangeArea":
		return
	overlaps.append(area)


func _on_area_2d_area_exited(area: Area2D) -> void:
	overlaps.erase(area)
