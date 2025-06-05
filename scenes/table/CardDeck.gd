extends Area2D

# 卡牌数据
var suits = ["clubs", "diamond", "heart", "spade"]
var ranks = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

# 存储所有卡牌和分配记录
var all_cards = []
var drawn_cards = []
var card_assignments = {}  # 新增：记录卡牌分配

func _ready():
	# 初始化完整牌组
	for suit in suits:
		for rank in range(1, 14):
			all_cards.append("%s_%d" % [suit, rank])
	all_cards.shuffle()

# 修改抽牌方法，添加分配记录
func draw_random_card(is_player: bool):
	if all_cards.size() == 0:
		print("牌组已空！")
		return null
	
	var card_code = all_cards.pop_back()
	drawn_cards.append(card_code)
	card_assignments[card_code] = is_player  # 记录分配
	
	var suit = card_code.split("_")[0]
	var rank = int(card_code.split("_")[1])
	var display_rank = ranks[rank - 1]
	
	var target = "玩家" if is_player else "对手"
	print("[%s] 抽到: %s %s (剩余: %d)" % [target, suit, display_rank, all_cards.size()])
	return card_code

func get_card_texture(card_code):
	var texture_path = "res://assets/cards/card_%s.png" % card_code
	if ResourceLoader.exists(texture_path):
		return load(texture_path)
	push_error("卡牌纹理不存在: " + texture_path)
	return null

func reset_deck():
	all_cards = []
	drawn_cards = []
	card_assignments = {}  # 重置分配记录
	_ready()
