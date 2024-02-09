extends Node2D

func _process(_delta):
	update_display()
	
func update_display():
	# hand
	for i in range(len($"..".hand)):
		var card_display = get_child(i)
		card_display.value = $"..".hand[i].value
	
	# new card
	var newcard_display = get_child(4)
	if get_node('/root/Game').new_cards[$".."] != null:
		newcard_display.show()
		newcard_display.value = get_node('/root/Game').new_cards[$".."].value
	else:
		newcard_display.hide()
