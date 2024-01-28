extends Node

var deck = []
var pile = []

func get_card(list):
	if list.size() > 0:
		return list.back()
	else:
		return null

func get_pop_card(list):
	if list.size() > 0:
		return list.pop_back()
	else:
		return null

func deal_card(list, player):
	if list.size() > 0:
		var new_card = get_pop_card(list)
		TurnSystem.new_cards[player] = new_card
		for card in player.hand:
			card.can_select = true

func get_sum(list):
	var total = 0
	for card in list:
		total += card.value
	return total

func get_best_card(list, player):
	var sums = []
	for i in range(len(list)):
		sums.append(get_sum(list) - list[i].value + TurnSystem.new_cards[player].value)

	if sums.min() < get_sum(list):
		return list[sums.find(sums.min())]
	else:
		return null

func _process(_delta):
	print(deck)
	print(pile)
	if deck.size() == 0:
		deck.append_array(pile)
		pile = pile.slice(-1)
		deck.shuffle()
