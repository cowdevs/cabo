extends Resource
class_name GameData

const CARD = preload("res://src/card/card.tscn")

@export var players: Array
@export var num_players: int
@export var card_movement_speed: float

@export_group('Card Lists')
@export var deck: Array
@export var pile: Array

@export_group('Delays')
@export var very_long_delay: float
@export var long_delay: float
@export var medium_delay: float
@export var short_delay: float
@export var very_short_delay: float
@export_group("")

func create_deck() -> void:
	deck.clear()
	for value in [0, 13]:
		for i in range(2):
			var card_instance = CARD.instantiate()
			card_instance.value = value
			deck.append(card_instance)
	
	for value in range(1, 13):
		for i in range(4):
			var card_instance = CARD.instantiate()
			card_instance.value = value
			deck.append(card_instance)
