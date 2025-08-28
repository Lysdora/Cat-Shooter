extends Node2D

@onready var label: Label = $UI/Score/Label
@onready var hearts := [
	$UI/Vie/Heart1,
	$UI/Vie/Heart2,
	$UI/Vie/Heart3
]
@onready var game_over: Panel = $UI/GameOver
@onready var retry_btn: Button = $UI/GameOver/RetryBTN
@onready var quit_btn: Button = $UI/GameOver/QuitBTN


func _ready() -> void:
	# connecter le signal du player
	var player = $Player
	player.armor_changed.connect(_on_armor_changed)
	game_over.process_mode = Node.PROCESS_MODE_ALWAYS
	

	label.text = str(Game.score)                      # juste le nombre
	Game.score_changed.connect(_on_score_changed)     # connexion du signal

func _on_score_changed(new_score: int) -> void:
	label.text = str(new_score)                       # mise à jour


func _on_armor_changed(new_value: int):
	_update_hearts(new_value)
	if new_value <= 0:
		game_over.visible = true
		Game.score = 0
		get_tree().paused = true

func _update_hearts(current_armor:int):
	for i in range(hearts.size()):
		hearts[i].visible = i < current_armor


func _on_retry_btn_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_btn_pressed() -> void:
	get_tree().quit()
