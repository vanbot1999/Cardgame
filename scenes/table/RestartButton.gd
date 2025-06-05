extends Button

@onready var card_system = $"../CardDeck"
@onready var deck_button = $"../DeckButton"
@onready var settle_button = $"../SettleButton"
@onready var player_hand = $"../PlayerHand"
@onready var enemy_hand = $"../EnemyHand"

func _ready():
	connect("pressed", Callable(self, "_on_button_pressed"))

func _on_button_pressed():
	# 重置牌组
	card_system.reset_deck()
	
	# 重置按钮状态
	deck_button.disabled = false
	deck_button.text = "抽牌"
	
	settle_button.disabled = true  # 结算按钮保持禁用直到可以结算
	settle_button.text = "结算"
	settle_button.modulate = Color(1, 1, 1)  # 恢复颜色
	
	# 清空手牌显示
	for i in range(1, 6):
		player_hand.get_node("Card%d" % i).visible = false
		enemy_hand.get_node("Card%d" % i).visible = false
	
	# 重置手牌计数
	deck_button.player_hand_size = 0
	deck_button.enemy_hand_size = 0
	
	print("\n===== 对局已重置 =====\n")
	
	# 恢复结算按钮
	$"../SettleButton".mouse_filter = MOUSE_FILTER_STOP
	$"../PlayerScoreDisplay".visible = false
	$"../PlayerScoreDisplay".text = "点数: 0"

