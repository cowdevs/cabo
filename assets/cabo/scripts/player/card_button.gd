extends TextureButton

signal pressed_button(index: int)
signal button_hovered(index: int, bool)

@onready var player = $"../.."

func _ready():
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_pressed():
	emit_signal("pressed_button", $"..".get_children().find(self))

func _on_mouse_entered():
	if player.get_new_card():
		var button_hover = create_tween()
		button_hover.tween_property(player.get_new_card(), 'global_position', player.get_hand()[$"..".get_children().find(self)].global_position + Vector2(0, -92), player.GAME.CARD_MOVEMENT_SPEED)

func _on_mouse_exited():
	if player.get_new_card():
		var button_hover = create_tween()
		button_hover.tween_property(player.get_new_card(), 'position', Vector2.ZERO, player.GAME.CARD_MOVEMENT_SPEED / 1.5)
