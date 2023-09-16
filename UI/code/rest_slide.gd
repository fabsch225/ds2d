extends ScrollContainer

var index = {
	"gear": 0,
	"crafting": 885,
	"upgrades": 1774
}
var positions = [0, 885, 1774]
var names = ["Equip Gear", "Craft Gear", "Upgrade Character"]

var last = 0
var t
var speed = 0
var direction = 1


func _ready():
	set_process(false)
	yield(get_tree().create_timer(0.5), "timeout")
	update_buttons()
	

func _process(delta):
	scroll_horizontal += speed * delta * direction
	print(scroll_horizontal, t, last)
	speed += min(abs(t - scroll_horizontal), abs(t - last))# * direction
	
	if (abs(scroll_horizontal - t) < 50):
		last = t
		scroll_horizontal = t
		speed = 0
		update_buttons()
		set_process(false)

func next():
	speed = 0
	var ci = positions.find(last)
	
	if ci + 1 == len(positions):
		return
		#t = positions[0]
	else:
		t = positions[ci + 1]
		
	if t < last:
		direction = -1
	else:
		direction = 1
	set_process(true)
	Hud.rest.stop_drag()

func prev():
	speed = 0
	var ci = positions.find(last)
	if ci - 1 == -1:
		return
		#t = positions[len(positions) - 1]
	else:
		t = positions[ci - 1]
		
	if t < last:
		direction = -1
	else:
		direction = 1
	set_process(true)
	Hud.rest.stop_drag()

func update_buttons():
	var ci = positions.find(last)
	Hud.rest.get_node("TextureRect/TextureRect/Control/arrows/right").disabled = ci == 0
	Hud.rest.get_node("TextureRect/TextureRect/Control/arrows/left").disabled = ci == len(positions) - 1
	Hud.rest.get_node("TextureRect/TextureRect/Control/RichTextLabel").text = names[ci]
	
func set_slide(s):
	speed = 0
	t = index[s]
	
	if t < last:
		direction = -1
	else:
		direction = 1
		
	set_process(true)
	Hud.rest.stop_drag()


func _on_right_pressed():
	if (speed == 0):
		prev()
		

func _on_left_pressed():
	if (speed == 0):
		next()
		
