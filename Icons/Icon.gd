extends TextureButton

onready var icon = $Icon
onready var inv = Hud.get_node("inv")

var index = null
var dragged = false
var pos = null

func _ready():
	pass
	
func set_icon(name):
	icon.frame = PlayerData.gear[name].i

func set_target(node):
	inv = node

func _on_button_button_down():
	inv.start_drag(index, icon.frame)
	icon.visible = false

func _on_button_button_up():
	yield(get_tree().create_timer(0.1), "timeout")
	inv.stop_drag()
	icon.visible = true

func _on_button_pressed():
	var item = PlayerData.global.gear_stored[index]
	
	inv.active.set_info(item)
	


