extends Button

var XYZ = 0


func _on_pressed() -> void:
	$"../EnemySpawner".start_next_wave()
	XYZ += 1
	$".".text = str(XYZ)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		_on_pressed()
