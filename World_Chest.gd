extends Node2D

var storage = [PlayerData.gear.Neon_Suit,PlayerData.gear.Neon_Suit,PlayerData.gear.Neon_Suit,PlayerData.gear.Neon_Suit]

export var display_name = "Just a Chest"
export var short_name = "Chest"

export var items = []


var open = false

func _ready():
	fill(items)
	
func fill(i):
	storage = [];
	for n in i:
		 storage.append(PlayerData.gear_accses[n])

func take(index):
	var item = storage[index]
	storage.remove(index)
	items.remove(index)
	PlayerData.store(item)
	#PlayerData.global.gear_stored.append(item);
	Hud.update_inv()

func take_all():
	for item in storage:
		PlayerData.store(item)
		#PlayerData.global.gear_stored.append(item)
	storage = []
	items = []
	Hud.update_inv()

func _on_Area2D_body_entered(body):
	if body == PlayerData.player and !open:
		Hud.chest_prompt.start(self,short_name)


func _on_Area2D_body_exited(body):
	if body == PlayerData.player and open:
		close()
	elif body == PlayerData.player:
		Hud.chest_prompt.stop()
	
	
func open():
	open = true
	Hud.chest.start()
	Hud.chest._update(self)
	$AnimatedSprite.animation = "Chest1OPEN"

func close():
	open = false
	Hud.chest.stop()
	$AnimatedSprite.animation = "Chest1CLOSE"

