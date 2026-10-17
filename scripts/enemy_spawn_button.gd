extends Button

var XYZ = 0


func _on_pressed() -> void:
	$"../EnemySpawner".spawn_enemy()
	XYZ += 1
	$".".text = str(XYZ)
