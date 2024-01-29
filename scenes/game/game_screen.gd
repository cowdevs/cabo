extends Node2D

var Player = preload("res://scenes/game/player/player/player.tscn")
var Computer = preload("res://scenes/game/player/computer/computer.tscn")
var player1 = Player.instantiate()
var player2 = Computer.instantiate()

func _ready():
	TurnSystem.add_player(player1)
	TurnSystem.add_player(player2)
	
	for i in range(TurnSystem.player_list.size()):
		TurnSystem.new_cards[TurnSystem.player_list[i]] = null
	
	set_player_positions()
	
	for player in TurnSystem.player_list:
		add_child(player)

	CardSystem.deck.shuffle()
	
	for player in TurnSystem.player_list:
		$Deck.first_hand(player)
	
	var first_card = CardSystem.get_pop_card(CardSystem.deck) 
	first_card.discard()

	CardSystem.update_deck_display()
	CardSystem.update_pile_display()
	
	TurnSystem.start_game()

func set_player_positions():
	var positions = [Vector2(800, 1050), Vector2(800, 150), Vector2(150, 600), Vector2(1450, 600)]
	var rotations = [0, PI, PI / 2, -(PI / 2)]
	for player in TurnSystem.player_list:
		player.position = positions[TurnSystem.player_list.find(player)]
		player.rotation = rotations[TurnSystem.player_list.find(player)]
