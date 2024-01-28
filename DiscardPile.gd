extends Node2D

signal drawn_from_pile

func _process(_delta):
	if Cards.pile.size() > 0:
		$DiscardPileFrames.frame = Cards.get_card(Cards.pile).value
	else:
		$DiscardPileFrames.frame = 15

func _on_button_pressed():
	for player in TurnSystem.player_list:
		if player.can_draw:
			Cards.deal_card(Cards.pile, player)
			player.can_draw = false
