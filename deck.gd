extends Node2D

var card_scene = preload("res://card.tscn")

signal drawn_from_deck

func _ready():
	create_deck()

func _process(_delta):
	$DeckTexture.frame = ceil(2.0 * type_convert(len(Cards.deck), TYPE_FLOAT) / 13.0)

func create_deck():
	for value in [0, 13]:
		for i in range(2):
			var card_instance = card_scene.instantiate()
			card_instance.value = value
			Cards.deck.append(card_instance)
	
	for value in range(1, 13):
		for i in range(4):
			var card_instance = card_scene.instantiate()
			card_instance.value = value
			Cards.deck.append(card_instance)

func first_hand(player):
	for i in range(4):
		var card = Cards.get_pop_card(Cards.deck)
		player.hand.append(card)

func _on_button_pressed():
	for player in TurnSystem.player_list:
		if player.can_draw:
			Cards.deal_card(Cards.deck, player)
			player.can_draw = false
