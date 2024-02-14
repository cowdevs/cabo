class_name Deck
extends CardList

func _ready():
	create_deck()
	shuffle()
	disable(self)
	update()

func _on_button_pressed():
	for player in $"../Players".get_children():
		if player.can_draw:
			draw_card(player)
			player.disable_cabo_button()
			update()
			disable(self)

func create_deck() -> void:
	cards.clear()
	for value in [0, 13]:
		for i in range(2):
			var card_instance = card_scene.instantiate()
			card_instance.value = value
			cards.append(card_instance)
	
	for value in range(1, 13):
		for i in range(4):
			var card_instance = card_scene.instantiate()
			card_instance.value = value
			cards.append(card_instance)

func update() -> void:
	$Texture.frame = ceil(2.0 * type_convert(len(cards), TYPE_FLOAT) / 13.0)
