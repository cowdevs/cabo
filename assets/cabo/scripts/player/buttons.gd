extends TextureButton

signal pressed_button(index: int)
signal hovered_button(index: int)

func _ready():
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)

func _on_pressed():
	emit_signal("pressed_button", $"..".get_children().find(self))

func _on_mouse_entered():
	emit_signal("hovered_button", $"..".get_children().find(self))
