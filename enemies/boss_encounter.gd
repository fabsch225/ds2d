extends Node2D

export var boss_name = "Temporary name please remove"

onready var area = $Area2D
var enemies = []
var bar = 0
var act = false
var disabled = false


func _ready():
	$Timer.stop()
	var bodies = area.get_overlapping_bodies()
	for b in bodies:
		#print(b)
		if b.is_in_group("enemy"):
			enemies.append(b)
			

#func _on_Area2D_body_entered():
#	print("Hello There")


func _on_Area2D_body_entered(body):
	
	if body == PlayerData.player and !act and !disabled:
		act = true
		$Timer.start()
		get_tree().call_group("barrier", "start")
		bar = 0
		var bodies = area.get_overlapping_bodies()
		for b in bodies:
			if b.is_in_group("enemy"):
				enemies.append(b)
				if b.boss:
					bar += b.hp
		
		Hud.boss.start(bar, boss_name)
	

func _on_Timer_timeout():
	if !act:
		return
	enemies = []
	bar = 0
	var bodies = area.get_overlapping_bodies()
	for b in bodies:
		if b.is_in_group("enemy"):
			enemies.append(b)
			if b.boss:
				bar += b.hp
	
	Hud.boss.update_health(bar)
	print(bar)
	if bar <= 0:
		yield(get_tree().create_timer(0.5), "timeout")
		enemies = []
		bar = 0
		bodies = area.get_overlapping_bodies()
		for b in bodies:
			if b.is_in_group("enemy"):
				enemies.append(b)
				if b.boss:
					bar += b.hp
		if bar <= 0:
			act = false
			disabled = true
			get_tree().call_group("barrier", "stop")
			$Timer.stop()
			if (PlayerData.player.WITH_SAVES):
				PlayerData.s(PlayerData.save_data.pos)
			yield(get_tree().create_timer(0.75), "timeout")
			Hud.boss.stop()
