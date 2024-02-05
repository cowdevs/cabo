extends Node

var deck
var pile

func _ready():
	deck = []
	pile = []

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
		get_node('/root/GameScreen').set_new_card(player, pop_card(list))
		if player.is_human:
			get_node('/root/GameScreen/ActionButtons/CaboButton').disabled = true
		player.can_draw = false

func get_sum(list):
	var total = 0
	for i in list:
		if i != null:
			total += i.value
	return total

func get_best_card(list, player):
	var sums = []
	for i in range(len(list)):
		if list[i] != null:
			sums.append(get_sum(list) - list[i].value + get_node('/root/GameScreen').new_cards[player].value)

	if sums.min() < get_sum(list):
		return list[sums.find(sums.min())]
	else:
		return null

func all_int(list):
	for item in list:
		if typeof(item) != TYPE_INT:
			return false
	return true

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
