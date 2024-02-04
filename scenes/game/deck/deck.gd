extends Node2D

var card_scene = preload("res://scenes/card/card.tscn")

func _ready():
	create_deck()
	CardSystem.update(CardSystem.deck)

func _process(_delta):
	for player in $"../Players".get_children():
		if player.is_player:
			$DeckButton.disabled = false if not player.has_new_card and player.can_draw else true

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
	for player in $"../Players".get_children():
		if player.can_draw:
			CardSystem.deal_card(CardSystem.deck, player)
			player.can_draw = false
