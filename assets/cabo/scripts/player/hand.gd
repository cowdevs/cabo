extends Node2D

func _process(_delta):
	update()
	
func update():
	# hand
	for i in range(len($"..".hand)):
		var card_display = get_child(i)
		card_display.value = $"..".hand[i].value
	
	# new card
	var newcard_display = get_child(4)
	if $"..".is_human:
		newcard_display.face = 'FRONT'
	if $"..".new_card != null:
		newcard_display.show()
		newcard_display.value = $"..".new_card.value
	else:
		newcard_display.hide()
