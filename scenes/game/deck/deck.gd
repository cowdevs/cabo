extends Node2D

var card_scene = preload("res://scenes/card/card.tscn")

func _ready():
	create_deck()
	CardSystem.update(CardSystem.deck)

func create_deck():
	for value in [0, 13]:
		for i in range(2):
			var card_instance = card_scene.instantiate()
			card_instance.value = value
			CardSystem.deck.append(card_instance)
	
	for value in range(1, 13):
		for i in range(4):
			var card_instance = card_scene.instantiate()
			card_instance.value = value
			CardSystem.deck.append(card_instance)

func first_hand(player):
	for i in range(4):
		var card = CardSystem.pop_card(CardSystem.deck)
		player.hand.append(card)

func _on_button_pressed():
	for player in TurnSystem.player_list:
		if player.can_draw:
			CardSystem.deal_card(CardSystem.deck, player)
			player.can_draw = false
