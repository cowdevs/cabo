extends Control

const PLAYER_ICON = preload("res://assets/cabo/textures/gui/icons/player_icon.aseprite")
const COMPUTER_ICON = preload("res://assets/cabo/textures/gui/icons/computer_icon.aseprite")

@onready var game_node = $".."
@onready var slots_node = $PanelContainer/MarginContainer/VBoxContainer/MarginContainer/Slots

signal new_round

func _ready():
	for slot in slots_node.get_children():
		slot.hide()
		slot.get_node('MarginContainer/CrownIcon').hide()
		slot.get_node('CenterContainer/CaboIconContainer/CaboIcon').hide()

func _on_next_round_pressed():
	new_round.emit()
	for slot in slots_node.get_children():
		slot.get_node('MarginContainer/CrownIcon').hide()
		slot.get_node('CenterContainer/CaboIconContainer/CaboIcon').hide()

func popup() -> void:
	$Animation.play('popup')

func declare_winner(player: Player) -> void:
	$PanelContainer/MarginContainer/VBoxContainer/Label.text = str(player) + " WAS CLOSEST TO CABO!"

func display_scoreboard() -> void:
	for i in range(game_node.get_node('Players').get_child_count()):
		slots_node.get_child(i).show()
	
	# find player with smallest hand
	var min_sum = INF
	var lowest_hand = null
	for player in game_node.get_node('Players').get_children():
		var player_sum = game_node.sum(player.hand)
		if player_sum < min_sum:
			min_sum = player_sum
			lowest_hand = player
			
	# calculate and display scores
	for player in game_node.get_node('Players').get_children():
		if player == game_node.cabo_caller:
			if player == lowest_hand:
				player.score_added = 0
			else:
				player.score_added = Scoreboard.add_score(10 + game_node.sum(player.hand), player)
		else:
			player.score_added = Scoreboard.add_score(game_node.sum(player.hand), player)
	
	var sorted_players = game_node.get_sorted_players(Scoreboard.get_scoreboard())
	for i in range(sorted_players.size()):
		var player = sorted_players[i]
		slots_node.get_child(i).get_node('ScoreContainer/ScoreLabel').text = str(Scoreboard.get_score(player))
		slots_node.get_child(i).get_node('AddScoreContainer/AddScoreLabel').text = "+" + str(player.score_added)
		
		if player.is_human:
			slots_node.get_child(i).get_node('CenterContainer/Icon').texture = PLAYER_ICON
			slots_node.get_child(i).get_node('CenterContainer/NameContainer/NameLabel').text = ''
		else:
			slots_node.get_child(i).get_node('CenterContainer/Icon').texture = COMPUTER_ICON
			slots_node.get_child(i).get_node('CenterContainer/NameContainer/NameLabel').text = str(player.name_label)
		
		if player == game_node.cabo_caller:
			slots_node.get_child(i).get_node('CenterContainer/CaboIconContainer/CaboIcon').show()
		
		if player in Scoreboard.get_winning_players():
			slots_node.get_child(i).get_node('MarginContainer/CrownIcon').show()
		
	declare_winner(lowest_hand)
	popup()
