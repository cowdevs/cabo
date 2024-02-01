extends Node2D

signal action_confirm(action)

func _process(_delta):
	for player in TurnSystem.player_list:
		if player.is_player:
			$PileButton.disabled = false if player.has_new_card or player.can_draw else true

func _on_button_pressed():
	for player in TurnSystem.player_list:
		if player.can_draw:
			CardSystem.deal_card(CardSystem.pile, player)
			player.can_draw = false
			break
		if player.is_player and player.has_new_card:
			TurnSystem.new_cards[player].discard()
			player.has_new_card = false
			for button in player.get_node('Buttons').get_children():
				button.disabled = true
			if TurnSystem.new_cards[player].value in range(7, 13):
				if TurnSystem.new_cards[player].value in [7, 8]:
					emit_signal('action_confirm', 'peek')
				elif TurnSystem.new_cards[player].value in [9, 10]:
					emit_signal('action_confirm', 'spy')
				elif TurnSystem.new_cards[player].value in [11, 12]:
					emit_signal('action_confirm', 'swap')
				TurnSystem.new_cards[player] = null
			else:
				TurnSystem.new_cards[player] = null
				TurnSystem.end_turn()
			break
