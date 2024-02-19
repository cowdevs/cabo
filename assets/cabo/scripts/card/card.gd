class_name Card
extends Control

@export var value: int
@export_enum("FRONT", "BACK") var face := "BACK"

func _to_string():
	return str(value)

func flip():
	if face == 'FRONT':
		$Animation.play('flip')
	else:
		$Animation.play_backwards('flip')
