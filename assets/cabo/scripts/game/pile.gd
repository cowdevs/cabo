extends CardList

signal action_confirm(action, player)

func _ready():
	disable()

func _process(_delta):
	if $Button.is_hovered() and not $Button.is_disabled():
		$Button/ButtonHover.show()
		$Button/ButtonHover.play()
	else:
		$Button/ButtonHover.hide()
		$Button/ButtonHover.stop()

func _on_button_pressed():
	for player in $"../Players".get_children():
		if player.can_draw:
			draw_card(player)
			update()
			disable()
		elif player.is_human and player.has_new_card:
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
