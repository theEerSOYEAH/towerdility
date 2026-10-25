extends Label


func _process(_delta):
	text = "Base HP: " + str(GameManager.health)
