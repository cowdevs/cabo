extends Node2D

signal action_confirm(action)

func _process(_delta):
	for player in $"../Players".get_children():
		if player.is_player:
			$PileButton.disabled = false if player.has_new_card or player.can_draw else true

func _on_button_pressed():
	for player in $"../Players".get_children():
		if player.can_draw:
			CardSystem.deal_card(CardSystem.pile, player)
		elif player.is_player and player.has_new_card:
			var card = TurnSystem.new_cards[player]
			card.discard()
			if card.value in range(7, 13):
				if card.value in [7, 8]:
					emit_signal('action_confirm', 'peek')
				elif card.value in [9, 10]:
					emit_signal('action_confirm', 'spy')
				elif card.value in [11, 12]:
					emit_signal('action_confirm', 'swap')
				TurnSystem.clear_new_card(player)
			else:
				TurnSystem.clear_new_card(player)
				TurnSystem.end_turn()
