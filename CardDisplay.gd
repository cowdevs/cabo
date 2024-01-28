extends Node2D

var card_scene = preload("res://card.tscn")

func _ready():
	await $"..".hand.is_empty() == false
	for marker in $"../Slots".get_children():
		var card_instance = card_scene.instantiate()
		card_instance.position = marker.position
		add_child(card_instance)
	get_children()[4].face = 'Front'

func _process(_delta):
	update_display()
	
func update_display():
	# hand
	for card in $"..".hand:
		var card_display = get_children()[$"..".hand.find(card)]
		card_display.value = card.value
	
	# new card
	if TurnSystem.new_cards[$".."] != null:
		get_children()[4].show()
		get_children()[4].value = TurnSystem.new_cards[$".."].value
	else:
		get_children()[4].hide()
	
	for button in $"../Buttons".get_children():
		var card = $"..".hand[button.get_index()]
		if card.can_select == false:
			button.disabled = true
		else:
			button.disabled = false
