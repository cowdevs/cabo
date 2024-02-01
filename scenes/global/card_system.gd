extends Node

var deck = []
var pile = []


func get_card(list):
	if list.size() > 0:
		return list.back()
	else:
		return null

func pop_card(list):
	if list.size() > 0:
		var card = list.pop_back()
		CardSystem.update(list)
		return card
	else:
		return null

func deal_card(list, player):
	if list.size() > 0:
		var new_card = pop_card(list)
		TurnSystem.new_cards[player] = new_card
		if player.is_player:
			player.has_new_card = true
			for button in player.get_node('Buttons').get_children():
				button.disabled = false

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

func update(list):
	if list == deck:
		get_node('/root/GameScreen/Deck/DeckTexture').frame = ceil(2.0 * type_convert(len(deck), TYPE_FLOAT) / 13.0)
	if list == pile:
		get_node('/root/GameScreen/Pile/PileTexture').frame = get_card(pile).value if pile.size() > 0 else 15
	
func _process(_delta):
	if deck.size() == 0:
		deck.append_array(pile)
		pile = pile.slice(-1)
		deck.shuffle()