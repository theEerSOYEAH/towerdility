extends StaticBody2D


@export var smilles_per_tick = 1
@export var interval : float= 1.0

func _ready() -> void:
	var timer = Timer.new()
	timer.wait_time = interval
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func _on_timer_timeout():
	GameManager.add_smiles(smilles_per_tick)
