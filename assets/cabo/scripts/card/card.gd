class_name Card
extends Control

signal card_pressed(index: int)
signal card_hovered(index: int, bool)

@export var value: int
@export_enum("FRONT", "BACK") var face := "FRONT"

func _ready():
	disable_button()

func _to_string():
	return str(value)

func flip():
	if face == 'FRONT':
		$Animation.play('flip')
	else:
		$Animation.play_backwards('flip')

func disable_button():
	$CardButton.disabled = true

func enable_button():
	$CardButton.disabled = false

func _on_card_button_pressed():
	card_pressed.emit(get_index())

func _on_card_button_mouse_entered():
	card_hovered.emit(get_index(), true)

func _on_card_button_mouse_exited():
	card_hovered.emit(get_index(), false)
