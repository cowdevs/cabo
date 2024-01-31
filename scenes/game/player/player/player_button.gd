extends TextureButton

signal pressed_button(index)

func _ready():
	pressed.connect(_on_button_pressed)

func _on_button_pressed():
	emit_signal("pressed_button", $"..".get_children().find(self))
