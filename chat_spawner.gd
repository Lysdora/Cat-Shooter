extends Node2D

const CHAT_SCENE = preload("res://cat.tscn")
@onready var spawner_cat: Node2D = $spawner_cat


func spawn_point():
	var points = spawner_cat.get_children()
	var random_points = points.pick_random()
	return random_points.global_position

func spawn_chat():
	var enemy_chat = CHAT_SCENE.instantiate()
	var world = get_tree().current_scene
	world.add_child(enemy_chat)
	var spawn_position = spawn_point()
	enemy_chat.global_position = spawn_position


func _on_timer_timeout() -> void:
	spawn_chat()	
