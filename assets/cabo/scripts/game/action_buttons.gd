extends Control

func _ready():
	$"../Pile".connect('action_confirm', _on_action_confirm)

func _on_action_confirm(_action):
	show_buttons()
	
func _on_yes_button_pressed():
	hide_buttons()
	
func _on_no_button_pressed():
	hide_buttons()
	$"..".end_turn()
		
func hide_buttons():
	for button in get_children():
		button.hide()
		button.disabled = true

func show_buttons():
	for button in get_children():
		button.show()
		button.disabled = false
