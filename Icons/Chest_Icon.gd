extends TextureButton

onready var icon = $Icon
onready var display = Hud.get_node("chest")
var chest

var index = null
var dragged = false
var pos = null

func _ready():
	pass
	
func set_icon(name):
	icon.frame = PlayerData.gear[name].i

func set_chest(c):
	chest = c


func _on_button_pressed():
	var item = chest.storage[index]
	
	display.set_info(item)
	display.sel_index = index
	
	


