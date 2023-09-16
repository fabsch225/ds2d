extends VBoxContainer

func _ready():
	pass 


func _on_resume_pressed():
	Hud.change_mode("game")

func _on_quit_pressed():
	get_tree().quit()

func _on_reload_pressed():
	Nav.queue = []
	get_tree().reload_current_scene()
