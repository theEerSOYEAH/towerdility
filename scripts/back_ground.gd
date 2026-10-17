extends TextureRect

@export var speed = Vector2(-20, 20)
var title = Vector2.ZERO

func _ready():
	title = texture.get_size()
	size = get_viewport_rect().size + title * 2
	position = -title


func _process(delta):
	position += speed * delta
	position.x = fposmod(position.x, title.x) - title.x
	position.y = fposmod(position.y, title.y) - title.y
