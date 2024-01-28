extends Node2D

@export var value: int
@export var face = 'Front'
var can_discard = true
var can_select = false

func _to_string():
	return str(value)	
	
func flip():
	if self.face == 'Front':
		$Animation.play('flip')
	else:	
		$Animation.play_backwards('flip')

func discard():
	if can_discard:
		self.face = 'Front'
		Cards.pile.append(self)
		self.can_discard = false

