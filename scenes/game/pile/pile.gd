extends Node2D

signal action_confirm(action)

func _ready():
	disable()

func _on_button_pressed():
	for player in $"../Players".get_children():
		if player.can_draw:
			CardSystem.deal_card(CardSystem.pile, player)
			disable()
		elif player.is_human and player.has_new_card:
			disable()
			var card = get_node('/root/GameScreen').new_cards[player]
			card.discard()
			if card.value in range(7, 13):
				if card.value in [7, 8]:
					emit_signal('action_confirm', 'peek')
				elif card.value in [9, 10]:
					emit_signal('action_confirm', 'spy')
				elif card.value in [11, 12]:
					emit_signal('action_confirm', 'swap')
				get_node('/root/GameScreen').clear_new_card(player)
			else:
				get_node('/root/GameScreen').clear_new_card(player)
				get_node('/root/GameScreen').end_turn()

func enable():
	$PileButton.disabled = false
	
func disable():
	$PileButton.disabled = true
