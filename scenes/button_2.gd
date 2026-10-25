extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var t = get_tree().get_first_node_in_group("selected_towers")
	visible = t != null and t.has_method("hire_farmer") and not t.has_farmer
	if visible:
		text = "hirefarmer" + str(t.farmer_cost)

func _on_pressed() -> void:
	var t = get_tree().get_first_node_in_group("selected_towers")
	if t.has_method("hire_farmer"):
		t.hire_farmer()
