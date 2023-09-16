extends Area2D

var rng = RandomNumberGenerator.new()

func _ready():
	pass

func process(delta):
	pass
#	var bodies = self.get_overlapping_bodies()
#	if (len(bodies) != 0):
#		print("YAY", bodies)

func light(right = true, delays = []):
	$light_left.disabled = !right
	$light_right.disabled = right
	
	$light_left.visible = !right
	$light_right.visible = right
	
	var d = PlayerData.global.dmg_light / len(delays)
	
	for delay in delays:
		yield(get_tree().create_timer(delay), "timeout")
	
		damage(d)
		
	disable_all()
		
	yield(get_tree().create_timer(1), "timeout")
	disable_visibility()
	
func heavy(right = true, delays = []):
	var d = PlayerData.global.dmg_heavy / len(delays)
	
	$heavy_left.disabled = right
	$heavy_right.disabled = !right

	$heavy_left.visible = !right
	$heavy_right.visible = right
	
	for delay in delays:
		yield(get_tree().create_timer(delay), "timeout")
		damage(d)
		
	disable_all()
	
	yield(get_tree().create_timer(1), "timeout")
	disable_visibility()
			
func disable_all():
	$light_left.disabled = true
	$light_right.disabled = true
	$heavy_left.disabled = true
	$heavy_right.disabled = true
	
func disable_visibility():
	$light_left.visible = false
	$light_right.visible = false
	$heavy_left.visible = false
	$heavy_right.visible = false
	

func damage(d):
	var bodies = get_overlapping_bodies()
	
	var enhancement = "none#!#!"
	
	if (PlayerData.global.gear_active[2] == PlayerData.gear.Talisman_Of_The_Abyss):
		enhancement = "coa"
	
	for b in bodies:
		if b.is_in_group("enemy") and b.state != 1:
			if (PlayerData.player.god):
				b.dmg(100000000)
				return
			if (b.is_in_group(enhancement)):
				print(b, d * 2, "damage dealt (Enhanced x2)")
				b.dmg(d * 2)
			else:
				print(b, d, "damage dealt")
				b.dmg(d)
			if (b.hp <= 0):
				if (b.boss):
					PlayerData.global.points += 1
					PlayerData.global.temp_points += 1
				elif (rng.randi_range(1,10) % 10 == 0):
					PlayerData.global.points += 1
					PlayerData.global.temp_points += 1
					print("you gained points")
