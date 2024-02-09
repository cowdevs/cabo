extends Node2D

var card_scene = preload("res://assets/cabo/scenes/card.tscn")

func _ready():
	for marker in get_children():
		var card_instance = card_scene.instantiate()
		card_instance.position = marker.position
		$"../Hand".add_child(card_instance)
