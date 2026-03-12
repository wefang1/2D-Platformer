extends Area2D

@export var move_direction : Vector2
@export var move_speed : float = 20 

@onready var start_position : Vector2 = global_position
@onready var target_position : Vector2 = global_position + move_direction

func _ready():
	$AnimationPlayer.play("fly")

func _physics_process(delta):
	global_position = global_position.move_toward(target_position, move_speed * delta)
	
	
	if  global_position == target_position:
		if target_position == start_position:
			target_position = start_position + move_direction
		else:
			target_position = start_position

func _on_body_entered(body):
	if not body.is_in_group("Player"):
		return
		
	print("damage")
