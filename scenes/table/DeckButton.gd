extends Button

@export var card_scale = Vector2(0.2, 0.2)
@export var hand_margin = 150
@export var horizontal_spacing = 180.0
@export var left_margin : float = 300


var player_hand_size = 0
var enemy_hand_size = 0
const MAX_HAND_SIZE = 5

@onready var card_system = $"../CardDeck"
@onready var player_hand = $"../PlayerHand"
@onready var enemy_hand = $"../EnemyHand"
@onready var score_label = $"../PlayerScoreDisplay"

func _ready():
	score_label.visible = false
	connect("pressed", Callable(self, "_on_button_pressed"))
	init_hand_position(player_hand, false)
	init_hand_position(enemy_hand, true)
	update_score_display()  # 初始化分数显示

func init_hand_position(hand_container: Node2D, is_enemy: bool):
	var viewport_size = get_viewport_rect().size
	var available_width = viewport_size.x - left_margin
	var start_x = left_margin + (available_width - (MAX_HAND_SIZE * horizontal_spacing)) / 2
	var pos_y = hand_margin if is_enemy else viewport_size.y - hand_margin
	
	for i in range(1, MAX_HAND_SIZE + 1):
		var card = hand_container.get_node("Card" + str(i))
		card.visible = false
		card.scale = card_scale
		card.position = Vector2(
			start_x + (i-1)*horizontal_spacing,
			pos_y
		)

func _on_button_pressed():
	if player_hand_size >= MAX_HAND_SIZE:
		print("玩家手牌已满！")
		return
	
	if card_system.all_cards.size() < 2:
		print("牌组不足，无法抽牌！")
		disabled = true
		text = "牌组已空"
		return
	
	# 统一使用带参数的抽牌调用
	var player_card = card_system.draw_random_card(true)  # true表示玩家
	setup_card(player_hand, player_hand_size, player_card)
	player_hand_size += 1
	
	if enemy_hand_size < MAX_HAND_SIZE:
		var enemy_card = card_system.draw_random_card(false)  # false表示对手
		setup_card(enemy_hand, enemy_hand_size, enemy_card)
		enemy_hand_size += 1
	
	update_score_display()  # 每次抽牌后更新分数
	# 根据手牌数量显示/隐藏Label
	score_label.visible = player_hand_size > 0
	
	if player_hand_size > 0:
		$"../SettleButton".disabled = false
	
	if player_hand_size >= MAX_HAND_SIZE:
		disabled = true
		text = "手牌已满"
		$"../SettleButton".disabled = false  # 手牌满时启用结算按钮

# 新增：计算并更新分数显示
func update_score_display():
	if player_hand_size == 0:
		score_label.visible = false
		return
	
	var total_score = 0
	for i in range(1, player_hand_size + 1):
		var card = player_hand.get_node("Card%d" % i)
		if card.visible and card.texture:
			total_score += get_card_value(card.texture.resource_path)
	
	score_label.text = "点数: %d" % total_score
	score_label.visible = true

# 新增：获取单张卡牌分值
func get_card_value(tex_path: String) -> int:
	if "back" in tex_path: return 0
	
	var file_name = tex_path.get_file()
	if "_" in file_name:
		var parts = file_name.split("_")
		if parts.size() >= 3:
			var rank = parts[2].split(".")[0]
			match rank:
				"A": return 1
				"J","Q","K": return 10
				_: 
					if rank.is_valid_int():
						return rank.to_int()
	return 0
	
	
func setup_card(hand, index, card_code):
	var card = hand.get_node("Card%d" % (index + 1))
	if card and card_code:
		card.texture = card_system.get_card_texture(card_code)
		card.visible = true
		if hand == enemy_hand:
			card.texture = load("res://assets/cards/card_back.png")
		if hand == player_hand:
			update_score_display()
