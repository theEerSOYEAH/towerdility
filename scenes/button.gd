extends Button


@onready var lock_button: Button = $"."


func _ready() -> void:
	lock_button.pressed.connect(_on_pressed)
	
func _process(delta: float) -> void:
	var t = get_tree().get_first_node_in_group("lock_target")
	visible = t != null and t.selected
	if visible :
		text = "unlock" if t.locked else "lock"
		
		

func _on_pressed() -> void:
	var t = get_tree().get_first_node_in_group("lock_target")
	print("button pressed, tower:", t, "locked:", t.locked if t else "none")
	if t == null:
		return
	if t.locked:
		t.unlock()
	else:
		t.start_locking()
