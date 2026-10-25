extends CanvasLayer



func _on_map_1_mouse_entered() -> void:
	$Map1.scale.x = 1.2
	$Map1.scale.y = 1.2


func _on_map_1_mouse_exited() -> void:
	$Map1.scale.x = 1.0
	$Map1.scale.y = 1.0
