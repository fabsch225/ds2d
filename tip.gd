extends TextureRect

onready var text = $text

func _ready():
	pass 
	
func new_tip():
	var tips = PlayerData.tips
	text.text = tips[randi() % tips.size()]



func _on_TextureButton_pressed():
	new_tip()
	
