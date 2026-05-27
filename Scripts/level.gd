extends Node2D

@onready var pause_menu = $PauseMenu

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			pause_menu.close()
		else:
			pause_menu.open()

func _ready():
	Playerstats.level_start_score = Playerstats.score
