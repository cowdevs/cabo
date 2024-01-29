extends Node2D

@export var value: int
@export var face = 'Front'

func _to_string():
	return str(value)	
	
func flip():
	if self.face == 'Front':
		$Animation.play('flip')
	else:	
		$Animation.play_backwards('flip')

func discard():
	self.face = 'Front'
	CardSystem.pile.append(self)
