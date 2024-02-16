extends Control

const PLAYER_ICON = preload("res://assets/cabo/textures/gui/icons/player_icon.aseprite")
const COMPUTER_ICON = preload("res://assets/cabo/textures/gui/icons/computer_icon.aseprite")

@onready var game_node = $".."
@onready var slots_node = $PanelContainer/MarginContainer/VBoxContainer/MarginContainer/Slots

signal new_round

func _ready():
	for slot in slots_node.get_children():
		slot.hide()

func _on_next_round_pressed():
	new_round.emit()

func popup() -> void:
	$Animation.play('popup')

func declare_winner(player: Player) -> void:
	$PanelContainer/MarginContainer/VBoxContainer/Label.text = str(player) + " WAS CLOSEST TO CABO!"

func calculate_scores() -> void:
	# find player with smallest hand
	var min_sum = INF
	var lowest_hand = null
	for player in game_node.get_node('Players').get_children():
		var player_sum = game_node.sum(player.hand)
		if player_sum < min_sum:
			min_sum = player_sum
			lowest_hand = player
	
	declare_winner(lowest_hand)
	
	# calculate scores
	for player in game_node.get_node('Players').get_children():
		if player == game_node.cabo_caller:
			if player != lowest_hand:
				Scoreboard.add_score(10 + game_node.sum(player.hand), player)
		else:
			Scoreboard.add_score(game_node.sum(player.hand), player)
	
	print(Scoreboard.get_scoreboard())

func display_scoreboard() -> void:
	for i in range(game_node.get_node('Players').get_child_count()):
		slots_node.get_child(i).show()
	var sorted_players = game_node.get_sorted_players(Scoreboard.get_scoreboard())
	for i in range(sorted_players.size()):
		if sorted_players[i].is_human:
			slots_node.get_child(i).get_node('CenterContainer/Icon').texture = PLAYER_ICON
		else:
			slots_node.get_child(i).get_node('CenterContainer/Icon').texture = COMPUTER_ICON
		slots_node.get_child(i).get_node('Label').text = str(Scoreboard.get_score(sorted_players[i]))
	popup()
