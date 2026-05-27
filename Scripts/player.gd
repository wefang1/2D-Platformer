extends CharacterBody2D

signal OnUpDateHealth (health : int)
signal OnUpDateScore (score : int)
signal OnUpDateTimeLeft (time_left : int)
signal Damaged
@export var move_speed : float = 100
@export var acceleration : float = 50
@export var breaking : float = 20
@export var gravity : float = 500
@export var jump_force : float = 200

@export var climb_force : float = 100

@export var health : int = 3

var move_input : float
var is_climbing = false

var visited_tiles = {}
var last_tile = Vector2i.ZERO

var time_left : int =100

@export var max_stamina : float = 100
@export var stamina : float = 100
@export var stamina_cost : float = 1

@onready var tilemap = $"../TileMap/Land"
@onready var sprite : Sprite2D = $Sprite
@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var audio : AudioStreamPlayer = $AudioStreamPlayer
@onready var timer : Timer = $CanvasLayer/Timer
@onready var stamina_bar = $CanvasLayer/StaminaBar

var take_damgage_sfx : AudioStream = preload("res://Audio/take_damage.wav")
var coin_sfx : AudioStream = preload("res://Audio/coin.wav")

func _ready():
	timer.timeout.connect(_on_timer_timeout)

func time_start(amount : int):
	time_left -= amount
	
	if time_left < 0:
		time_left = 0
	
	OnUpDateTimeLeft.emit(time_left)
	
	if timer.is_stopped():
		timer.start()

	if time_left <= 0:
		game_over()

func _on_timer_timeout():
	time_left -= 1
	
	if time_left < 0:
		time_left = 0
	
	OnUpDateTimeLeft.emit(time_left)
	
	if time_left <= 0:
		timer.stop()
		game_over()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	move_input = Input.get_axis("move_left", "move_right")
	
	if move_input != 0:
		velocity.x = lerp(velocity.x, move_input * move_speed, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, breaking * delta)
	
	if Input.is_action_pressed("jump") and is_on_floor() and not is_climbing:
		velocity.y = -jump_force
	
	if is_climbing:
		climb_()
	
	move_and_slide()
	
	if velocity.x != 0:
		check_new_tile()
	if velocity.x == 0 and velocity.y == 0:
		stamina += 10 * delta
	stamina_bar.value = stamina
	
	if stamina == 0:
		velocity.x = 0
		velocity.y = 0

func _process(delta): 
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
	
	if global_position.y > 200:
		game_over()
	_manage_animation()

func _manage_animation():
	if not is_on_floor():
		if not is_climbing:
			anim.play("jump")
		else:
			anim.play("idle")
	elif move_input != 0:
		anim.play("move")
	else:
		anim.play("idle")

func take_damage(amount : int):
	health -= amount
	OnUpDateHealth.emit(health)
	Damaged.emit()
	_damage_flash()
	play_sound(take_damgage_sfx)
	
	if health <= 0:
		call_deferred("game_over")

func game_over():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func increase_score(amount: int):
	Playerstats.score += amount
	OnUpDateScore.emit(Playerstats.score)
	play_sound(coin_sfx)

func _damage_flash():
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.05).timeout
	sprite.modulate = Color.WHITE

func check_new_tile():
	var tile_pos = tilemap.local_to_map(global_position)
	if tile_pos != last_tile:
		last_tile = tile_pos
		if not visited_tiles.has(tile_pos):
			visited_tiles[tile_pos] = true
			stamina -= stamina_cost
			stamina = clamp(stamina, 0, max_stamina)

func climb_():
	velocity.y = 0
	if Input.is_action_pressed("climb_up"):
		velocity.y = -climb_force
	elif Input.is_action_pressed("climb_down"):
		velocity.y = climb_force

func play_sound (sound : AudioStream):
	audio.stream = sound
	audio.play()
