extends CardList

func _ready():
	create_deck()
	shuffle()
	disable()
	update()

func _on_button_pressed():
	for player in $"../Players".get_children():
		if player.can_draw:
			draw_card(player)
			player.can_draw = false

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

func enable() -> void:
	$Button.disabled = false
	
func disable() -> void:
	$Button.disabled = true
