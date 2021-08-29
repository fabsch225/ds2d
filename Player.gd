extends KinematicBody2D

const WITH_SAVES = false

var move_vec = Vector2()

var move_speed = 50		#depends on weight
var default_move_speed = 130
var move_speed_modifier = float(move_speed) /  default_move_speed
var max_move_speed = 230
var min_move_speed = 70

var real_grav = 0
var gravity = 8
var less_gravity = 7
var jump_force = 460
var velo = Vector2()
var last_velo = Vector2()
var drag = 0.5

const jump_buffer = 0.08
var time_pressed_jump = 0.0
var time_left_ground = 0.0
var last_grounded = true#false

var facing_right = true
var attacking = false
var wait_dropdown_attack = false
var stunned = false
var dashing = false

var dash_duration = 0.3
var dash_end = 0.45
var dash_speed = 320
var recover_speed = 1
var dash_block = 1
var dash_timestamp = 0
var normal_speed = move_speed
var dashed_once = false

var attack_dur = 0.9
var dash_attack_dur = 1.2
var jump_attack_dur = 1.2

var light_delay_a = 0.35
var light_delay_b = 0.25
var heavy_delay = 0.15

var agility = float(2)
var health = 100
var stamina = 100
var invoulnerable = false


var stamina_recharge = 0
var health_recharge = 0


onready var anim_player = $AnimationPlayer

var dead = false

func set_text(t):
	$RichTextLabel.text = str(t)


func _ready():
	randomize()
	get_tree().call_group("need_player_ref", "set_player", self)
	PlayerData.set("player", self)
	
	if (WITH_SAVES):
		PlayerData.l()
	else:
		PlayerData.start()
	
	Hud.change_mode("game")
	Hud.update_inv()
	
func damage(d):
	if (invoulnerable):
		return
	var defense = PlayerData.global.defense / 2 / float(100)
	health -= d * (1 - PlayerData.global.defense / float(100))
	print("Defense: ", defense)
	print("Damage Taken: ", d * (1 - defense), "  (", (1 - defense), " %)")

func _process(delta):
	update_sprite()
	Hud.bars.set_bars(health, stamina)
	
	if (stamina < PlayerData.global.stats.stamina):
		stamina += stamina_recharge
	
	if Input.is_action_pressed("exit"):
		get_tree().quit()
	if Input.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	if Input.is_action_pressed("pause"):
		Hud.change_mode("pause")
	if Input.is_action_pressed("inv"):
		Hud.change_mode("inv")
	if Input.is_action_pressed("map"):
		Hud.change_mode("map")

func _physics_process(delta):
	
	if !dead:
		if (!dashing and !stunned):
			move_vec = Vector2()
			if Input.is_action_pressed("run_left"):
				move_vec.x -= 1
				
			if Input.is_action_pressed("run_right"):
				move_vec.x += 1
				
			if Input.is_action_pressed("dash") and move_vec != Vector2():
				if (!attacking and get_cur_time() - dash_timestamp > dash_block):
					dash_timestamp = get_cur_time()
					
					dash()
		
		if Input.is_action_pressed("attack"):
			attack()
			
	if (!attacking):
		velo += move_vec * move_speed - drag * Vector2(velo.x, 0)
	
	if (is_on_ceiling()):
		velo.y = 50
		velo.x = 0
		$ShakeCamera2D.add_trauma(0.1)
	if (is_on_wall()):
		if (dashing):
			dashing = false
	
	
	var cur_grounded = is_on_floor()
	if !cur_grounded and last_grounded:
		time_left_ground = get_cur_time()
	if cur_grounded:
		dashed_once = false
	
	var will_jump = false
	var pressed_jump = Input.is_action_just_pressed("jump") and !attacking and !dashing
	
	if pressed_jump:
		time_pressed_jump = get_cur_time()
	
	if (pressed_jump and cur_grounded):
		jump()
	elif (!last_grounded and cur_grounded and get_cur_time() - time_pressed_jump < jump_buffer):
		jump()
	elif pressed_jump and get_cur_time() - time_left_ground < jump_buffer:
		jump()
	
	if Input.is_action_pressed("jump"):
		real_grav += less_gravity / 2
		velo.y += real_grav / 1.25
	else:
		real_grav += gravity / 2
		velo.y += real_grav / 1.25
	
	
		
	move_and_slide(velo, Vector2.UP)
	
	if cur_grounded:
		if (!last_grounded):
			print("Landing Force", velo.y)
			if (wait_dropdown_attack and Input.is_action_pressed("attack") and !dashing and !attacking):
				attack()
				$ShakeCamera2D.add_trauma(0.3, true)
			
			if velo.y < 1400:
				pass
			elif velo.y < 3000:
				$ShakeCamera2D.add_trauma(0.25)
				stun(0.3, 0.8)
				play_anim("Stop_Dash")
			elif velo.y < 4500:
				$ShakeCamera2D.add_trauma(0.35)
				stun(0.3, 1)
				play_anim("Stop_Dash")
			else:
				$ShakeCamera2D.add_trauma(0.45)
				stun(0.3, 1)
				play_anim("Stop_Dash")
			
		if velo.y > 10:
			velo.y = 10
		real_grav = 0

	else:
		if dashing or stunned:
			velo.y = 0
		
	if (!dashing and !attacking and !stunned):
		if move_vec.x > 0.0 and !facing_right:
			flip()
		elif move_vec.x < 0.0 and facing_right:
			flip()
		if cur_grounded:
			if move_vec == Vector2():
				play_anim("Idle")
			else:
				play_anim("Run", 2, move_speed_modifier)
				
		else:
			if velo.y > 0.0:
				play_anim("Falling")
			else:
				play_anim("Jumping")
	
	
	
	last_grounded = cur_grounded
	last_velo = velo
	
func attack():
	if (stamina > 0):
		if (!wait_dropdown_attack):
			if (!dashing and is_on_floor()):
				if (!attacking):
					velo = Vector2()
					attacking = true
					anim_player.play("Attack_1", -1, agility)
					PlayerData.stamina_light()
					$hurtbox.light(facing_right, [light_delay_a * agility, light_delay_b * agility])
					yield(get_tree().create_timer(attack_dur * (1 / agility)), "timeout")
					attacking = false
					
			elif(is_on_floor()):		# and is_on_floor()
				dashing = false
				move_speed = normal_speed
				attacking = true
				velo = Vector2()
				anim_player.play("Dash_Attack", -1, agility)
				PlayerData.stamina_heavy()
				$hurtbox.heavy(facing_right, [heavy_delay * agility])
				yield(get_tree().create_timer(dash_attack_dur * (1 / agility)), "timeout")
				attacking = false
				
			elif (!dashing):
				wait_dropdown_attack = true
				
		elif(is_on_floor() and !dashing):
			move_speed = normal_speed
			attacking = true
			wait_dropdown_attack = false
			velo = Vector2()
			anim_player.play("Dash_Attack", -1, agility)
			PlayerData.stamina_heavy()
			$hurtbox.heavy(facing_right, [heavy_delay * agility])
			yield(get_tree().create_timer(jump_attack_dur * (1 / agility)), "timeout")
			attacking = false
			
func jump():
	if dead:
		return
	else:
		if (stamina > 0):
			PlayerData.stamina_jump()
			velo.y = -jump_force

func stun(t,modifier):
	stunned = true
	move_speed *= modifier
	yield(get_tree().create_timer(t * (1 / agility)), "timeout")
	stunned = false
	move_speed = normal_speed
	
func dash():
	if (!dashed_once and stamina > 0):
		PlayerData.stamina_dash()
		
		$ShakeCamera2D.smoothing_speed = 2.5
		dashed_once = true
		dashing = true
		set_collision(false)
		move_speed = dash_speed
		play_anim("Start_Dash")
		yield(get_tree().create_timer(dash_duration), "timeout")
		
		if (!dashing or !is_on_floor()):
			$ShakeCamera2D.smoothing_speed = 5
			dashing = false
			move_speed = normal_speed
			set_collision(true)
			return
		$ShakeCamera2D.smoothing_speed = 5
		play_anim("Stop_Dash")
		set_collision(true)
		move_speed = recover_speed
		yield(get_tree().create_timer(dash_end), "timeout")
		if (!dashing):
			set_collision(true)
			return
		move_speed = normal_speed
		dashing = false
		
		real_grav = 0

func get_cur_time():
	return OS.get_ticks_msec() / 1000.0

func set_collision(collide_with_monsters):
	invoulnerable = !collide_with_monsters
	set_collision_mask_bit(2, collide_with_monsters)
	
	
func flip():
	var correction = 15
	
	$Base_Sprite.flip_h = !$Base_Sprite.flip_h
	facing_right = !facing_right
	$Collision_Left.disabled = !facing_right
	$Collision_Right.disabled = facing_right
	
#	$hurtbox.get_node("light_left").disabled = !facing_right
#	$hurtbox.get_node("light_right").disabled = facing_right
#	$hurtbox.get_node("heavy_left").disabled = !facing_right
#	$hurtbox.get_node("heavy_right").disabled = facing_right
	
	if (facing_right):
		teleport(Vector2(correction,0))
	else:
		teleport(Vector2(-correction,0))

func update_sprite():
	for c in $Base_Sprite.get_children():
		c.flip_h = $Base_Sprite.flip_h
		c.frame = $Base_Sprite.frame


func teleport(t, rel=true):
	if rel:
		translate(t)
	else:
		position = t

func play_anim(anim, prio=2, speed=1.0):		#1 -> run and idle anims (Looping stuff); 2 -> other stuff, cannot chancel, 3 -> can chancel other anims; 
	match prio:
		1:
			if (anim_player.current_animation != anim and !anim_player.is_playing()):
				anim_player.play(anim, -1, speed)
		2:
			if (anim_player.current_animation != anim):
				anim_player.play(anim, -1, speed)
		3:
			anim_player.play(anim, -1, speed)
