extends TextureButton

onready var icon = $Icon
onready var inv = Hud.get_node("inv")

var index = null
var dragged = false
var pos = null
var amount = 1
var draggable = true

var recipe = false
var r_item = null

func _ready():
	pass
	
func set_icon(name):
	if name == null:
		$RichTextLabel.visible = false
		$Icon.frame = 299
		draggable = false
		return
	$Icon.frame = PlayerData.gear[name].i
	if (amount > 1):
		$RichTextLabel.visible = true
		$RichTextLabel.text = str(amount)
	else:
		$RichTextLabel.visible = false

func update_amount():
	if (amount > 1):
		$RichTextLabel.visible = true
		$RichTextLabel.text = str(amount)
	else:
		$RichTextLabel.visible = false

func set_target(node):
	inv = node

func _on_button_button_down():
	if (draggable):
		inv.start_drag(index, icon.frame)
		icon.visible = false

func _on_button_button_up():
	if (draggable):
		yield(get_tree().create_timer(0.1), "timeout")
		inv.stop_drag()
		icon.visible = true

func _on_button_pressed():
	if (draggable):
		var item = PlayerData.global.gear_stored[index]
		inv.active.set_info(item, amount)
	if (recipe and draggable):
		if (r_item != null):
			inv.set_craft_info(r_item, amount)
			print(r_item, amount)
			inv.find_recipes(r_item)
	if (recipe and !draggable):
		#var item = PlayerData.global.gear_stored[index]
		Hud.rest.set_craft_info(r_item, amount)
