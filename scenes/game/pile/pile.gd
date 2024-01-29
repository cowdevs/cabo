extends Node2D


func _on_button_pressed():
	for player in TurnSystem.player_list:
		if player.can_draw:
			CardSystem.deal_card(CardSystem.pile, player)
			CardSystem.update_pile_display()
			player.can_draw = false
		if player.is_player:
			if player.has_new_card:
				TurnSystem.new_cards[player].discard()
				CardSystem.update_pile_display()
				if TurnSystem.new_cards[player].value in [7, 8]:
					print('PEEK ACTION')
				elif TurnSystem.new_cards[player].value in [9, 10]:
					print('SPY ACTION')
				elif TurnSystem.new_cards[player].value in [11, 12]:
					print('SWAP ACTION')
				TurnSystem.new_cards[player] = null
				player.has_new_card = false
				TurnSystem.end_turn()
				break
