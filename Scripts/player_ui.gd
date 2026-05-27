extends CanvasLayer

@onready var health_container = $HealthContainer
var hearts : Array = []

@onready var score_text : Label = $ScoreText

@onready var player = get_parent()

@onready var time_text : Label = $TimeText


func _ready():
	hearts = health_container.get_children()
	
	time_text.visible = false
	
	player.OnUpDateHealth.connect(_update_hearts)
	player.OnUpDateScore.connect(_update_score)
	player.OnUpDateTimeLeft.connect(_update_time_left)
	player.Damaged.connect(_on_player_damage)
	
	_update_hearts(player.health)
	_update_score(Playerstats.score)
	_update_time_left(player.time_left)


func _update_hearts(health : int):
	for i in len(hearts):
		hearts[i].visible = i < health

func _update_score(score : int):
	score_text.text = "Socre: " + str(score)

func _update_time_left(time_left : int):
	time_text.text = "Time Left: " + str(time_left) + "s"

func _on_player_damage():
	time_text.visible = true
