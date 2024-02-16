extends Control

func _on_yes_button_pressed():
	hide_action_buttons()
	
func _on_no_button_pressed():
	hide_action_buttons()
	get_node('/root/Game').end_turn($"..")
		
func hide_action_buttons():
	for button in $ActionButtons.get_children():
		button.hide()
		button.disabled = true

func show_action_buttons():
	for button in $ActionButtons.get_children():
		button.show()
		button.disabled = false
