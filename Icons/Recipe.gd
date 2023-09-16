extends HBoxContainer



func _ready():
	pass # Replace with function body.

func set_recipe(r):
	$button.recipe = true 
	$button2.recipe = true 
	$button3.recipe = true 
	$button.draggable = false
	$button2.draggable = false
	$button3.draggable = false
	
	$button2.set_icon(null)
	
	var last = r[0]
	var last2 = null
	$button.set_icon(r[0].name)
	$button.r_item = r[0]
	for i in range(1, len(r) - 1):
		if (r[i] != last):
			$button2.set_icon(r[i].name)
			$button2.r_item = r[i]
			last2 = r[i]
		elif r[i] != last2:
			$button.amount += 1
		else:
			$button2.amount += 1

	$button3.set_icon(r[len(r) - 1].name)
	$button3.r_item = r[len(r) - 1]

	$button.update_amount()
	$button2.update_amount()
