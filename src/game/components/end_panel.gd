extends Control

const PLAYER_ICON = preload("res://assets/textures/gui/icons/player_icon.aseprite")
const COMPUTER_ICON = preload("res://assets/textures/gui/icons/computer_icon.aseprite")

@onready var GAME = get_node('/root/Game')
@onready var SLOTS = $PanelContainer/MarginContainer/VBoxContainer/MarginContainer/Slots

signal new_round

func _ready():
	for slot in SLOTS.get_children():
		slot.hide()
		slot.get_node('MarginContainer/CrownIcon').hide()
		slot.get_node('CenterContainer/CaboIconContainer/CaboIcon').hide()

func _on_next_round_pressed():
	await Transition.fade_in()
	new_round.emit()
	for slot in SLOTS.get_children():
		slot.get_node('MarginContainer/CrownIcon').hide()
		slot.get_node('CenterContainer/CaboIconContainer/CaboIcon').hide()
	Transition.fade_out()

func popup() -> void:
	$Animation.play('popup')

func declare_winner(player: Player) -> void:
	$PanelContainer/MarginContainer/VBoxContainer/Label.text = str(player) + " WAS CLOSEST TO CABO!"

func display_scoreboard() -> void:
	# find player with smallest hand
	var min_sum = INF
	var lowest_hand = null
	for i in range(GAME.get_node('GameContainer/Players').get_child_count()):
		SLOTS.get_child(i).show()
		var player = GAME.get_node('GameContainer/Players').get_child(i)
		var player_sum = GAME.sum(player.get_hand())
		if player_sum < min_sum:
			min_sum = player_sum
			lowest_hand = player
			
	# calculate and display scores
	for player in GAME.get_node('GameContainer/Players').get_children():
		if player == GAME.cabo_caller:
			if player == lowest_hand:
				player.score_added = 0
			else:
				player.score_added = Scoreboard.add_score(10 + GAME.sum(player.get_hand()), player)
		else:
			player.score_added = Scoreboard.add_score(GAME.sum(player.get_hand()), player)
	
	var sorted_players = GAME.get_sorted_players(Scoreboard.get_scoreboard())
	for i in range(sorted_players.size()):
		var player = sorted_players[i]
		SLOTS.get_child(i).get_node('ScoreContainer/ScoreLabel').text = str(Scoreboard.get_score(player))
		SLOTS.get_child(i).get_node('AddScoreContainer/AddScoreLabel').text = "+" + str(player.score_added)
		
		if player.is_player:
			SLOTS.get_child(i).get_node('CenterContainer/Icon').texture = PLAYER_ICON
			SLOTS.get_child(i).get_node('CenterContainer/NameContainer/NameLabel').text = ''
		else:
			SLOTS.get_child(i).get_node('CenterContainer/Icon').texture = COMPUTER_ICON
			SLOTS.get_child(i).get_node('CenterContainer/NameContainer/NameLabel').text = str(player.name_label)
		
		if player == GAME.cabo_caller:
			SLOTS.get_child(i).get_node('CenterContainer/CaboIconContainer/CaboIcon').show()
		
		if player in Scoreboard.get_winning_players():
			SLOTS.get_child(i).get_node('MarginContainer/CrownIcon').show()
		
	declare_winner(lowest_hand)
	popup()
