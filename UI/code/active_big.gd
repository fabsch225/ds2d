extends HBoxContainer

onready var my_children = {
	"sword": $sword,
	"armor": $armor,
	"accs": $accs
}


func _ready():
	pass

func set_items():
	var act = PlayerData.global.gear_active
	for slot in act:
		
		my_children[slot.type].get_child(0).frame = slot.i
		print(my_children[slot.type].get_child(0).frame)

func set_info(i, amount):
	Hud.rest.set_info(i, amount)

func _on_sword_pressed():
	var item = PlayerData.global.gear_active[0]
	Hud.rest.set_info(item, 1)

func _on_armor_pressed():
	var item = PlayerData.global.gear_active[1]
	Hud.rest.set_info(item, 1)
	
func _on_accs_pressed():
	var item = PlayerData.global.gear_active[2]
	Hud.rest.set_info(item, 1)
