extends PanelContainer

var tower = null
var just_opened = false

@onready var title_label = %TitleLabel
@onready var damage_button = %DamageButton
@onready var speed_button = %SpeedButton
@onready var range_button = %RangeButton
@onready var close_button = %CloseButton

func _ready():
	damage_button.pressed.connect(_on_damage_pressed)
	speed_button.pressed.connect(_on_speed_pressed)
	range_button.pressed.connect(_on_range_pressed)
	close_button.pressed.connect(_on_sell_pressed)

func _unhandled_input(event):
	if not visible:
		return
	if just_opened:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not get_global_rect().has_point(get_global_mouse_position()):
			close()

func show_for(new_tower):
	if is_instance_valid(tower):
		tower.set_selected(false)
	tower = new_tower
	tower.set_selected(true)
	visible = true
	refresh()
	
	var screen_pos = new_tower.get_global_transform_with_canvas().origin
	position.x = clamp(screen_pos.x + 50, 0, get_viewport_rect().size.x - size.x)
	position.y = clamp(screen_pos.y + 100, 0, get_viewport_rect().size.y - size.y)
	
	pivot_offset = size / 2
	scale = Vector2(0.8, 0.8)
	modulate.a = 0.0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.15)
	just_opened = true
	await get_tree().process_frame
	just_opened = false

func close():
	if is_instance_valid(tower):
		tower.set_selected(false)
	hide()

func refresh():
	if not is_instance_valid(tower):
		hide()
		return
	title_label.text = "Upgrades"
	damage_button.text = button_text("Damage", tower.damage_level)
	speed_button.text = button_text("Fire rate", tower.speed_level)
	range_button.text = button_text("Range", tower.range_level)
	
	damage_button.disabled = not can_buy(tower.damage_level)
	speed_button.disabled = not can_buy(tower.speed_level)
	range_button.disabled = not can_buy(tower.range_level)
	
	close_button.text = "Sell +" + str(int(tower.total_spent * 0.5))
func button_text(upgrade_name, level):
	var cost = tower.get_cost(level)
	if cost == -1:
		return upgrade_name + " (MAX)"
	return upgrade_name + " lvl " + str(level) + " - " + str(cost) + " smiles"

func _on_damage_pressed():
	tower.upgrade_damage()
	refresh()

func _on_speed_pressed():
	tower.upgrade_speed()
	refresh()
	
func _on_range_pressed():
	tower.upgrade_range()
	refresh()

func can_buy(level):
	var cost = tower.get_cost(level)
	return cost != -1 and GameManager.smiles >= cost
	

func _on_sell_pressed():
	if not is_instance_valid(tower):
		return
	var t = tower
	close()
	t.sell()

func _process(_delta):
	if visible:
		refresh()
