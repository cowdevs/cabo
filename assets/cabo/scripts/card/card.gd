class_name Card
extends Node2D

@export var value: int
@export_enum("Front", "Back") var face: String

func _ready():
	face = 'Front'

func _to_string():
	return str(value)
	
func flip():
	if face == 'Front':
		$Animation.play('flip')
	else:
		$Animation.play_backwards('flip')
