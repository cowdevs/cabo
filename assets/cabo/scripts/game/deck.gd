class_name Deck
extends Control

signal ready_to_start

const CARD = preload("res://assets/cabo/scenes/card.tscn")

@export var cards: Array[Card] = []

func _ready():
	$"../../EndPanel".connect('new_round', _on_new_round)
	create_deck()
	shuffle()
	disable()
	update()

func _process(_delta):
	update()

func _to_string():
	return str(cards)

func _on_new_round():
	clear()
	create_deck()
	shuffle()
	disable()
	update()

func _on_button_pressed():
	var player = $"../../..".current_player
	if player.is_human:
		if player.can_draw:
			draw_card(player)
			player.disable_cabo_button()
			update()
			disable()

func create_deck() -> void:
	cards.clear()
	for value in [0, 13]:
		for i in range(2):
			var card_instance = CARD.instantiate()
			card_instance.value = value
			cards.append(card_instance)
	
	for value in range(1, 13):
		for i in range(4):
			var card_instance = CARD.instantiate()
			card_instance.value = value
			cards.append(card_instance)

# METHODS
func get_top_card() -> Card:
	var card = cards.front()
	return card

func pop_top_card() -> Card:
	var card = cards.pop_front()
	return card

func add_card(card) -> void:
	cards.push_front(card)

func deal_cards() -> void:
	if cards.size() > 4:
		await get_tree().create_timer($"../../..".SHORT_SHORT).timeout
		for player in $"../..".get_node('Players').get_children():
			for i in range(4):
				var card = pop_top_card()
				card.position = Vector2(0, min(0, -4 * ($Texture.get_frame() - 1)))
				add_child(card)
				var deal_card_tween = create_tween()
				deal_card_tween.tween_property(card, 'global_position', player.global_position, 0.25)
				await deal_card_tween.finished
				remove_child(card)
				player.add_hand(card)
		emit_signal('ready_to_start')

func draw_card(player) -> void:
	if cards.size() > 0:
		var card = pop_top_card()
		card.position = Vector2(0, min(0, -4 * ($Texture.get_frame() - 1)))
		add_child(card)
		var draw_card_tween = create_tween()
		draw_card_tween.tween_property(card, 'global_position', player.get_node('NewCard').global_position, 0.25)
		if player.is_human:
			card.flip()
		await draw_card_tween.finished
		card.position = Vector2.ZERO
		if player.is_human:
			player.disable_cabo_button()
		remove_child(card)
		player.set_new_card(card)
		player.can_draw = false

# Vector2(0, min(0, -4 * ($Texture.get_frame() - 1)))

func empty() -> bool:
	return cards.is_empty()

func shuffle() -> void:
	cards.shuffle()

func clear() -> void:
	cards.clear()

func update() -> void:
	$Texture.frame = ceil((3.0 / 26.0) * type_convert(len(cards), TYPE_FLOAT))
	$Button.position = Vector2(-33, min(0, -4 * ($Texture.get_frame() - 1) - 45))

func enable() -> void:
	$Button.disabled = false
	
func disable() -> void:
	$Button.disabled = true
