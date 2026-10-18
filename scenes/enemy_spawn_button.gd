extends Button

var XYZ = 0


func _on_pressed() -> void:
	$"../EnemySpawner".start_next_wave()
	XYZ += 1
	$".".text = str(XYZ)
