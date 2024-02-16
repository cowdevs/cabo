class_name Card
extends Node2D

@export var value: int
@export_enum("FRONT", "BACK") var face: String

func _ready():
	face = 'FRONT'

func _to_string():
	return str(value)

func flip():
	if face == 'FRONT':
		$Animation.play('flip')
	else:
		$Animation.play_backwards('flip')
