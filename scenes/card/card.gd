extends Node2D

@export var value: int
@export var face = 'Back'

func _to_string():
	return str(value)
	
func flip():
	if face == 'Front':
		$Animation.play('flip')
		face = 'Back'
	else:	
		$Animation.play('flip')
		face = 'Front'

func discard():
	face = 'Front'
	CardSystem.pile.append(self)
	CardSystem.update(CardSystem.pile)
