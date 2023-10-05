extends CanvasLayer

onready var bars = $bars
onready var pause = $pause
onready var inv = $inv
onready var camp_fire = $camp_fire
onready var rest = $rest
onready var boss = $Boss
onready var use_elevator = $use_elevator
onready var call_elevator = $call_elevator
onready var chest = $chest
onready var chest_prompt = $chest_prompt

onready var tip = $pause/HBoxContainer/VBoxContainer2/tip

var mode = "nothing yet" #"game"
var cooldown = false

func _ready():
	pass
#	yield((get_tree().create_timer(0.5)), "timeout")
#	change_mode("game")

func reset():
	var children = get_children()
	for child in children:
		child.visible = false
		
	$fade.visible = true

func change_mode(t=null, skip=false):
	if (!cooldown or skip):
		cool()
		if (t != mode):
			reset()
			if t:
				mode = t
			match mode:
				"game":
					PlayerData.player.update_camera(true)
					#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
					bars.visible = true
#					if (camp_fire.act):
#						camp_fire.visible = true
					
				"pause":
					PlayerData.player.update_camera(false)
					#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					tip.new_tip()
					pause.visible = true
					bars.visible = true
				"inv":
					#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					inv.visible = true
					bars.visible = true
					get_tree().call_group("icons", "set_target",inv)
					if (camp_fire.act):
						camp_fire.visible = true
				"rest":
					PlayerData.player.update_camera(false)
					PlayerData.player.health = PlayerData.global.stats.health
					rest.visible = true
					bars.visible = true
					get_tree().call_group("ai_act","rest",false)
					get_tree().call_group("icons", "set_target",rest)
				"creds":
					fade(true);
					yield(get_tree().create_timer(1), "timeout")
					get_tree().change_scene("res://start.tscn")
					fade(false)
					$credits.visible = true
				"start":
					fade(true);
					yield(get_tree().create_timer(1), "timeout")
					$start.visible = true
					fade(false)
					
				
		else:
			match mode:
				"game":
					return
				"pause":
					change_mode("game", true)
					if (camp_fire.act):
						camp_fire.visible = true
				"inv":
					change_mode("game", true)
					if (camp_fire.act):
						camp_fire.visible = true
				

func cool():
	if (cooldown):
		return
	cooldown = true
	yield((get_tree().create_timer(0.5)), "timeout")
	cooldown = false


func update_inv():
	inv.update()
	rest.update()

func show_message(m):
	$message/TextureRect/RichTextLabel.text = m
	$message.visible = true
	$message/AnimationPlayer.play("Show")

func start_menu():
	pass
	#$credits.visible = false
	#$start.visible = true

func _on_wipe_pressed():
	var dir = Directory.new()
	dir.remove("user://savegame.save")


func _on_st_pressed():
	$fade/AnimationPlayer.play("fade_in");
	yield($fade/AnimationPlayer, "animation_finished");
	get_tree().change_scene("res://World.tscn")

func fade(f_in):
	if f_in:
		$fade/AnimationPlayer.play("fade_in");
	else:
		$fade/AnimationPlayer.play("fade_out");
		
func teleport(player, pos):
	player.temp_invo()
	fade(true)
	yield($fade/AnimationPlayer, "animation_finished");
	$fade/Sprite2.visible = true;
	player.can_move = 0;
	player.position = pos
	yield(get_tree().create_timer(2), "timeout")
	player.can_move = 1;
	$fade/Sprite2.visible = false;
	
	fade(false)

func restart():
	Hud.boss.stop()
	Nav.reset()
	
	PlayerData.player.temp_invo()
	fade(true)
	yield($fade/AnimationPlayer, "animation_finished");
	Nav.queue = []
	get_tree().reload_current_scene()
