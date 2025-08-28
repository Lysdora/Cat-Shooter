# 🚀 Cat Shooter – Godot 4 (Pixel 16×16)

Petit shooter vertical : un **player** tire des **bullets**, des **chats aliens** descendent, un **spawner** les génère, **score** + **vies** affichés en UI, **Game Over** avec Retry/Quit.

---

## 🎮 Contrôles
- `Left / Right` : déplacer le vaisseau
- `Shoot` : tirer (action input `shoot`)

---

## 🗂️ Structure du projet
```
project.godot
scenes/
  world.tscn
  player.tscn
  bullet.tscn
  cat.tscn
  spawner.tscn
UI/
  Score/Label
  Vie/Heart1..Heart3
  GameOver/RetryBTN, QuitBTN
scripts/
  Player.gd
  Bullet.gd
  Cat.gd
  ChatSpawner.gd
  World.gd
  Game.gd   (Autoload)
assets/
  sprites + sons
```

---

## 🧠 Autoload (score global)

`Game.gd` (singleton) :

```gdscript
extends Node
signal score_changed(score:int)
var score: int = 0

func add_score(amount: int):
    score += amount
    score_changed.emit(score)
```

Activer dans **Project Settings → AutoLoad** (`Game.gd`, nom `Game`).

---

## 🛩️ Player (Area2D)
- Déplacement horizontal
- Tire des bullets depuis `ShootPoint`
- Gère ses **vies** (`armor`)
- Émet le signal `armor_changed(int)` pour l’UI

```gdscript
@export var speed := 100.0
const BULLET_SCENE = preload("res://bullet.tscn")
@onready var shoot_point: Marker2D = $ShootPoint
@onready var shoot: AudioStreamPlayer = $shoot

var armor := 3
signal armor_changed(new_value:int)

func _physics_process(delta):
    if Input.is_action_pressed("left"):
        position.x -= speed * delta
    if Input.is_action_pressed("right"):
        position.x += speed * delta
    if Input.is_action_just_pressed("shoot"):
        shoot.play()
        var b = BULLET_SCENE.instantiate()
        get_tree().current_scene.add_child(b)
        b.position = shoot_point.global_position

func _on_area_entered(area: Area2D):
    armor -= 1
    armor_changed.emit(armor)
    if armor <= 0:
        queue_free()
        return
    area.queue_free()
```

---

## 🧨 Bullet (RigidBody2D)

```gdscript
extends RigidBody2D

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
    queue_free()
```

---

## 😼 Ennemi “Chat” (Area2D)

```gdscript
signal chat_mort
@export var speed := 20.0
@onready var hit: AudioStreamPlayer = $hit
@onready var explosion: AudioStreamPlayer = $explosion
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var armor := 3

func _process(delta): position.y += speed * delta

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
    await animation_player.animation_finished
    animation_player.play("idle")

func _on_visible_on_screen_notifier_2d_screen_exited(): queue_free()
```

---

## 🐾 Spawner (Node2D)

```gdscript
const CHAT_SCENE = preload("res://cat.tscn")
@onready var spawner_cat: Node2D = $spawner_cat

func spawn_point():
    var points = spawner_cat.get_children()
    var p = points.pick_random()
    return p.global_position

func spawn_chat():
    var e = CHAT_SCENE.instantiate()
    get_tree().current_scene.add_child(e)
    e.global_position = spawn_point()

func _on_timer_timeout(): spawn_chat()
```

---

## 🖥️ UI / World (Node2D)

```gdscript
@onready var label: Label = $UI/Score/Label
@onready var hearts := [$UI/Vie/Heart1, $UI/Vie/Heart2, $UI/Vie/Heart3]
@onready var game_over: Panel = $UI/GameOver

func _ready():
    var player = $Player
    player.armor_changed.connect(_on_armor_changed)
    game_over.process_mode = Node.PROCESS_MODE_ALWAYS

    label.text = str(Game.score)
    Game.score_changed.connect(_on_score_changed)

func _on_score_changed(v:int): label.text = str(v)

func _on_armor_changed(v:int):
    _update_hearts(v)
    if v <= 0:
        game_over.visible = true
        Game.score = 0
        get_tree().paused = true

func _update_hearts(v:int):
    for i in range(hearts.size()):
        hearts[i].visible = i < v

func _on_retry_btn_pressed():
    get_tree().paused = false
    get_tree().reload_current_scene()

func _on_quit_btn_pressed(): get_tree().quit()
```

---

## ✅ Check-list erreurs classiques
- `pick_random` → oublier `()` sur `get_children()`
- `hurt` invisible → `idle` rejoué chaque frame, vérifier que `hurt` n’est **pas en loop**
- Double `queue_free()` → erreur “previously freed instance”
- Projectile RigidBody2D → gérer dans `_on_body_entered`, pas dans `area_entered`
- Score non mis à jour → signal `score_changed` doit être émis avant `return`

---

## 🔊 Astuces sons
- Vérifier que le **stream** est assigné et que le **bus** n’est pas muet
- Si jeu en pause et le son doit jouer : `process_mode = PROCESS_MODE_ALWAYS`
