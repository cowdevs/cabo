class_name Deck
extends Control

const CARD = preload("res://assets/cabo/scenes/card.tscn")

@onready var GAME = get_node("/root/Game")
@onready var GAME_CONTAINER = get_node("/root/Game/GameContainer")

signal ready_to_start

var deck := true
var pile := false

var cards: Array[Card] = []

func _ready():
	GAME_CONTAINER.get_node('EndPanel').connect('new_round', _on_new_round)
	$Card.connect('card_pressed', _on_card_pressed)
	$Card.face = 'BACK'
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

func _on_card_pressed(_i):
	var player = GAME.current_player
	if player:
		if player.is_player:
			if player.can_draw:
				draw_from_deck(player)
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
		await get_tree().create_timer(GAME.SHORT_SHORT).timeout
		for player in GAME_CONTAINER.get_node('Players').get_children():
			for i in range(4):
				var card = pop_top_card()
				card.position = Vector2(0, min(0, -4 * ($Texture.get_frame() - 1)))
				add_child(card)
				var deal_card_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
				deal_card_tween.tween_property(card, 'global_position', player.global_position, GAME.CARD_MOVEMENT_SPEED / 2)
				await deal_card_tween.finished
				remove_child(card)
				player.add_hand(card, -1)
		
		await get_tree().create_timer(GAME.SHORT).timeout
		
		var first_card = pop_top_card()
		first_card.position = Vector2(0, min(0, -4 * ($Texture.get_frame() - 1)))
		add_child(first_card)
		var first_card_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		first_card_tween.tween_property(first_card, 'global_position', %Pile.global_position, GAME.CARD_MOVEMENT_SPEED)
		first_card.flip()
		await first_card_tween.finished
		remove_child(first_card)
		%Pile.discard(first_card)
		emit_signal('ready_to_start')

func draw_from_deck(player) -> void:
	if cards.size() > 0:
		var card = pop_top_card()
		card.position = Vector2(0, min(0, -4 * ($Texture.get_frame() - 1)))
		add_child(card)
		var draw_card_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		draw_card_tween.tween_property(card, 'global_position', player.get_node('NewCard').global_position, GAME.CARD_MOVEMENT_SPEED)
		if player.is_player:
			if card.face == 'BACK':
				card.flip()
		await draw_card_tween.finished
		card.position = Vector2.ZERO
		if player.is_player:
			player.disable_cabo_button()
		remove_child(card)
		player.set_new_card(card)
		update()
		player.can_draw = false

func empty() -> bool:
	return cards.is_empty()

func shuffle() -> void:
	cards.shuffle()

func clear() -> void:
	cards.clear()

func update() -> void:
	$Texture.frame = ceil((3.0 / 26.0) * type_convert(len(cards), TYPE_FLOAT))
	$Card.position = Vector2(0, min(0, -4 * ($Texture.get_frame() - 1)))

func enable() -> void:
	$Card.enable_button()
	
func disable() -> void:
	$Card.disable_button()

func is_enabled() -> bool:
	return not $Card.disabled
	
func is_disabled() -> bool:
	return $Card.disabled
