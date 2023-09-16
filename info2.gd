extends TextureRect
onready var r_template = preload("res://Icons/Recipe.tscn")
onready var text_temp = preload("res://UI/text.tscn")


func _ready():
	pass
#	yield(get_tree().create_timer(1.5), "timeout")
#	fill_all_recipes()

func fill_all_recipes():
	$ScrollContainer/VBoxContainer.delete_children()
	for r in PlayerData.recipes_accses:
		for i in r:
			if i in PlayerData.global.gear_stored and r.find(i) != len(r) - 1:
				var recipe = r_template.instance()
		
				#print(str(r[0].name))
				recipe.set_recipe(r)
				$ScrollContainer/VBoxContainer.add_child(recipe)
				break
		
		
func find_recipes(i):
	$ScrollContainer/VBoxContainer.delete_children()
	for r in PlayerData.recipes_accses:
		if i in r and r.find(i) != len(r) - 1:
			var recipe = r_template.instance()
			recipe.set_recipe(r)
			$ScrollContainer/VBoxContainer.add_child(recipe)
	if ($ScrollContainer/VBoxContainer.get_child_count() == 0):
		var t = text_temp.instance()
		t.text = "There are no Recipes with this item"
		$ScrollContainer/VBoxContainer.add_child(t)
