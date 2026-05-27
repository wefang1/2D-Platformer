extends CanvasLayer

func _ready():
	visible = false


func _on_resume_button_pressed():
	close()
	

func _on_restart_button_pressed() -> void:
	Playerstats.score = Playerstats.level_start_score
	get_tree().paused = false
	get_tree().reload_current_scene()
	

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()

func open():
	visible = true
	get_tree().paused = true

func close():
	visible = false
	get_tree().paused = false
