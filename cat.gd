extends Area2D
signal chat_mort
@export var speed: float = 20.0
@onready var hit: AudioStreamPlayer = $hit

var armor: int = 3
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var explosion: AudioStreamPlayer = $explosion

func _ready() -> void:
	animation_player.play("idle")
		

func _process(delta: float) -> void:
	position.y += speed * delta
	
func _on_body_entered(body: Node2D) -> void:
	armor -= 1
	if armor <= 0:
		body.queue_free()
		Game.add_score(1)
		chat_mort.emit()
		explosion.play()
		animation_player.play("dead")
		await animation_player.animation_finished
		queue_free()
		return
	hit.play()
	animation_player.play("hurt")
	await  animation_player.animation_finished
	animation_player.play("idle")

	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
