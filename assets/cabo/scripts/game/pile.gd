extends CardList

signal action_confirm(action)

func _ready():
	disable()

func _on_button_pressed():
	for player in $"../Players".get_children():
		if player.can_draw:
			draw_card(player)
			disable()
		elif player.is_human and player.has_new_card:
			disable()
			var card = player.new_card
			discard(card)
			player.clear_new_card()
			if card.value in range(7, 13):
				if card.value in [7, 8]:
					emit_signal('action_confirm', 'peek')
				elif card.value in [9, 10]:
					emit_signal('action_confirm', 'spy')
				elif card.value in [11, 12]:
					emit_signal('action_confirm', 'swap')
			else:
				$"..".end_turn()

func update() -> void:
	$Texture.frame = get_top_card().value if cards.size() > 0 else 15

func enable() -> void:
	$Button.disabled = false
	
func disable() -> void:
	$Button.disabled = true

func discard(card) -> void:
	add_card(card) 
	update()
