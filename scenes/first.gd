extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)
	
func _process(delta: float) -> void:
	var t = get_tree().get_first_node_in_group("selected_towers")
	visible = t != null and not t.follow_mouse
	if visible:
		text = "target" +  t.get_target_mode_name()
	
	



func _on_pressed() -> void:
	var t = get_tree().get_first_node_in_group("selected_towers")
	if t:
		t.cycle_target_mode()
