extends Node2D

@export var value: int
@export var face = 'Back'

func _to_string():
	return str(value)
	
func flip():
	if face == 'Front':
		$Animation.play('flip')
	else:	
		$Animation.play_backwards('flip')

func discard():
	CardSystem.pile.append(self)
	CardSystem.update(CardSystem.pile)
