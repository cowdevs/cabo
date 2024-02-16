class_name Deck
extends Node2D

const CARD = preload("res://assets/cabo/scenes/card.tscn")

@export var cards: Array[Card] = []

func _ready():
	$"../EndPanel".connect('new_round', _on_new_round)
	create_deck()
	shuffle()
	disable()
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
	var player = $"..".current_player
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

func deal_card(player) -> void:
	if cards.size() > 0:
		var card = pop_top_card()
		player.hand.append(card)

func draw_card(player) -> void:
	if cards.size() > 0:
		var card = pop_top_card()
		player.set_new_card(card)
		if player.is_human:
			player.get_node('Control/CaboButton').disabled = true
		player.can_draw = false

func empty() -> bool:
	return cards.is_empty()

func shuffle() -> void:
	randomize()
	cards.shuffle()

func clear() -> void:
	cards.clear()

func update() -> void:
	$Texture.frame = ceil(2.0 * type_convert(len(cards), TYPE_FLOAT) / 13.0)

func enable() -> void:
	$Button.disabled = false
	
func disable() -> void:
	$Button.disabled = true
