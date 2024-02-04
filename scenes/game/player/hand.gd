extends Node2D

var card_scene = preload("res://scenes/card/card.tscn")

func _ready():
	for marker in $"../Slots".get_children():
		var card_instance = card_scene.instantiate()
		card_instance.position = marker.position
		add_child(card_instance)
	if $"..".is_player:
		get_children()[4].face = 'Front'

func _process(_delta):
	update_display()
	
func update_display():
	# hand
	for i in range(len($"..".hand)):
		var card_display = $"..".find_in_hand(i)
		card_display.value = $"..".hand[i].value
	
	# new card
	if TurnSystem.new_cards[$".."] != null:
		get_children()[4].show()
		get_children()[4].value = TurnSystem.new_cards[$".."].value
	else:
		get_children()[4].hide()
	
	#print(str($"..") + str($"..".hand))
