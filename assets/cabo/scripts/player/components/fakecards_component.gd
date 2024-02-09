extends Node2D

func _ready():
	for card in get_children():
		card.visible = false
