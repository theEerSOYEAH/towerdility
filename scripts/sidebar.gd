extends Control

@export var collapsed_width: float = 60.0
@export var expanded_width: float = 200.0
@export var tween_duration: float = 0.25

var tween: Tween

func _ready() -> void:
	offset_left = -collapsed_width

func _on_mouse_entered() -> void:
	animate_width(expanded_width)

func _on_mouse_exited() -> void:
	animate_width(collapsed_width)

func animate_width(target_width: float) -> void:
	if tween and tween.is_running():
		tween.kill()
		
	tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "offset_left", -target_width, tween_duration)
	
	
		
		
