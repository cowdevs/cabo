class_name Pile
extends Deck

signal action_confirm(action, player)

func _ready():
	$"../EndPanel".connect('new_round', _on_new_round)
	disable()
	update()
	
func _on_new_round():
	clear()
	disable()
	update()

func _on_button_pressed():
	var player = $"..".current_player
	if player.is_human:
		if player.can_draw:
			draw_card(player)
			player.disable_cabo_button()
			update()
			disable()
		elif player.has_new_card:
			disable()
			var card = player.new_card
			discard(card)
			player.clear_new_card()
			if card.value in range(7, 13):
				if card.value in [7, 8]:
					action_confirm.emit('peek', player)
				elif card.value in [9, 10]:
					action_confirm.emit('spy', player)
				elif card.value in [11, 12]:
					action_confirm.emit('swap', player)
			else:
				$"..".end_turn(player)

func discard(card) -> void:
	add_card(card) 
	update()

func update() -> void:
	$Texture.frame = get_top_card().value if cards.size() > 0 else 15
