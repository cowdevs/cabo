extends Node2D

var Player = preload("res://scenes/game/player/player/player.tscn")
var Computer = preload("res://scenes/game/player/computer/computer.tscn")

func _ready():
	$Players.add_child(Player.instantiate())
	$Players.add_child(Computer.instantiate())
	
	for i in range($Players.get_child_count()):
		TurnSystem.new_cards[$Players.get_child(i)] = null
	
	set_player_positions()
	
	for player in $Players.get_children():
		TurnSystem.add_player(player)

	CardSystem.deck.shuffle()
	
	for player in $Players.get_children():
		$Deck.first_hand(player)
	
	var first_card = CardSystem.pop_card(CardSystem.deck) 
	first_card.discard()

	CardSystem.update(CardSystem.deck)
	CardSystem.update(CardSystem.pile)
	
	$ActionButtons.hide_buttons()
	
	TurnSystem.start_game()

func set_player_positions():
	var positions = [Vector2(800, 1050), Vector2(800, 150), Vector2(150, 600), Vector2(1450, 600)]
	var rotations = [0, PI, PI / 2, -(PI / 2)]
	for player in $Players.get_children():
		player.position = positions[$Players.get_children().find(player)]
		player.rotation = rotations[$Players.get_children().find(player)]
