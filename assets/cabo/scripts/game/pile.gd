class_name Pile
extends Deck

signal action(action, player)
signal button_hovered(bool)

func _ready():
	deck = false
	pile = true
	$"../EndPanel".connect('new_round', _on_new_round)
	$Card.connect('card_pressed', _on_card_pressed)
	$Card.connect('card_hovered', _on_card_hovered)
	$Card.face = 'FRONT'
	disable()
	update()

func _on_new_round():
	clear()
	disable()
	update()

func _on_card_pressed(_i):
	var player = GAME.current_player
	if player.is_player:
		if player.can_draw:
			draw_from_pile(player)
			player.disable_cabo_button()
			update()
			disable()
		elif player.has_new_card:
			disable()
			var card = player.get_new_card()
			discard(card)
			player.clear_new_card()
			if card.value in range(7, 13):
				if card.value in [7, 8]:
					action.emit('peek', player)
				elif card.value in [9, 10]:
					action.emit('spy', player)
				elif card.value in [11, 12]:
					action.emit('swap', player)
			else:
				GAME.end_turn(player)

func _on_card_hovered(_i, is_hovered):
	var player = GAME.current_player
	if player:
		if player.get_new_card():
			var button_hover = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
			if is_hovered:
				button_hover.tween_property(player.get_new_card(), 'scale', Vector2(1.1, 1.1), GAME.CARD_MOVEMENT_SPEED / 2)
				button_hover.tween_property(player.get_new_card(), 'global_position', global_position + Vector2(0, -28), GAME.CARD_MOVEMENT_SPEED)
			else:
				button_hover.tween_property(player.get_new_card(), 'scale', Vector2(1, 1), GAME.CARD_MOVEMENT_SPEED / 2)
				button_hover.tween_property(player.get_new_card(), 'position', Vector2.ZERO, GAME.CARD_MOVEMENT_SPEED / 2)

func draw_from_pile(player) -> void:
	if cards.size() > 0:
		var card = pop_top_card()
		card.position = Vector2.ZERO
		card.face = 'FRONT'
		add_child(card)
		var draw_card_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		draw_card_tween.tween_property(card, 'global_position', player.get_node('NewCard').global_position, GAME.CARD_MOVEMENT_SPEED)
		if player.is_computer:
			card.flip()
		await draw_card_tween.finished
		card.position = Vector2.ZERO
		if player.is_player:
			player.disable_cabo_button()
		remove_child(card)
		player.set_new_card(card)
		update()
		player.can_draw = false

func discard(card) -> void:
	add_card(card) 
	update()

func update() -> void:
	if cards.size() > 0:
		$Card.show()
		$Card.value = get_top_card().value
	else:
		$Card.hide()
