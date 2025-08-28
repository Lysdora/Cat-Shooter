extends Area2D

@export var speed: float = 100.0
const BULLET_SCENE = preload("res://bullet.tscn")
@onready var shoot_point: Marker2D = $ShootPoint
@onready var shoot: AudioStreamPlayer = $shoot

var armor: int = 3
signal armor_changed(new_value: int)

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("left"):
		position.x -= speed * delta
	if Input.is_action_pressed("right"):
		position.x += speed * delta
	if Input.is_action_just_pressed("shoot"):
		shoot.play()
		var bullet = BULLET_SCENE.instantiate()
		var world = get_tree().current_scene
		world.add_child(bullet)
		bullet.position = shoot_point.global_position



func _on_area_entered(area: Area2D) -> void:
	armor -= 1
	armor_changed.emit(armor) # avertir l'UI
	if armor <= 0:
		queue_free()
		return
	
	area.queue_free()
	
