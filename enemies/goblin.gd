extends KinematicBody2D

export var facing_right = true
export var boss = false
export var Php = 150


export var ranged = false
export var ranged_delay = 2
export var turns = true

onready var nav = get_parent()
onready var line = get_parent().get_parent().get_node("Debug")
onready var ray = $RayCast2D
onready var hurt = $hurt
onready var bullet = preload("res://enemies/Projectiles/bomb.tscn")

var player = null
var hp = 200
var RANGE = 1000
var DMG = 35

var speed = 130
var air_speed = 180

var gravity = 9
var real_grav = 0
var jump_force = -380
var jumping
var velocity = Vector2()


enum {
	CHASING = 0,
	DEAD =  1,
	IDLE = 2,
	PATR = 3,
	SHOOTING = 4,
}

var state = IDLE
var a
var b
var going_to_a = true
var waiting = false
export var forget_time = 20


var attacking = false
var ready = true
var general_delay = 0.8

var flip_tired_delay = 0.8
var flip_tired = false
var flip_waiting = false
var flip_delay = 0.1


var hitting = false
var charging = false
var dodgeable = false
var attack_recovering = false

var attack_length = 1.1
var attack_delay = 0.9
var dodge_window = 0.8
var real_attack_delay = attack_delay - dodge_window
var real_attack_length = attack_length - attack_delay

var attack_recover_time = 2
var attack_range = 80
var attack_trigger = 110
var reach = 170
var dir

func _ready():
	if len(get_children()) == 2:
		state = PATR
		a = get_node("A")
		b = get_node("B")
	
	hp = Php
	if (boss):
		forget_time = 120
	
	$Shoot.wait_time = ranged_delay
	
	var correction = 15
	print(facing_right)
	$AnimatedSprite.flip_h = !facing_right
	
	$Collision_Left.disabled = facing_right
	$Collision_Right.disabled = !facing_right
	
	if (facing_right):
		teleport(Vector2(correction,0))
	else:
		teleport(Vector2(-correction,0))
	
func dmg(d):
	hp -= d
	get_node("Enemy_Health_bar").update()
	if ranged:
		pass
	else:	
		state = CHASING
	
func die():
	if (state == DEAD):
		return
	state = DEAD
	
	$Timer.stop()
	$Shoot.stop()
	set_process(false)
	set_physics_process(false)
	$AnimatedSprite.animation = "Death"
	$Collision_Left.disabled = true	
	$Collision_Right.disabled = true	
	yield(get_tree().create_timer(0.6), "timeout")
	
	$AnimatedSprite.playing = false
	$AnimatedSprite.frame = 3
#	if $Timer != null:
#		$Timer.queue_free()
	
	
func _physics_process(_delta):
	var target
	match state:
		DEAD:
			return
		IDLE:
			$AnimatedSprite.animation = "Idle"
			if !is_on_floor():
				move_and_slide(Vector2(0,5))
			if (hp < 0):
				die()
			if (turns and player):
				if facing_right == (player.position.x < position.x):
					flip()
			return
		PATR:
			if going_to_a:
				target = a
			else:
				target = b
		CHASING:
			if player != null:
				target = player
		SHOOTING:
			if facing_right == (player.position.x < position.x) and turns:
				flip()
	if (hp < 0):
		die()
		return
		
	if (target != null):
		
		var d = position.distance_to(target.position)
		var d2 = $top.position.distance_to(target.position)
		
		var path = nav.get_simple_path(position, target.position)
		line.points = path
		
		if len(path) > 0:
			velocity.x = position.direction_to(path[1]).normalized().x * speed
		
		if (!is_on_floor()):
			velocity.x *= (air_speed / speed)
		
		if velocity.x > 0.0 and !facing_right:
			flip()
		elif velocity.x < 0.0 and facing_right:
			flip()
		
		if (d > attack_trigger or state == PATR) and len(path) > 0:
			if (position.direction_to(path[1]).normalized().y < -0.85):
				var d3 = abs(position.y - path[1].y) 
				if (is_on_floor() and !attacking):
					if (d3 < 300):
						velocity.y = -110
					if (d3 < 500):
						velocity.y = -230
					if (d3 < 1200):
						velocity.y = -380
					else:
						velocity.y = -600
					jumping = true
					
					print("jump target", d)
			elif (is_on_wall() and is_on_floor() and !attacking):
				jumping = true
				velocity.y = -110
				
		elif state != PATR and len(path) > 1:
			if (!attacking and !attack_recovering):
				attack()
		else:
			going_to_a != going_to_a
			
			
		if (!is_on_floor()):
			real_grav += gravity / 7
			velocity.y += real_grav / 2
		else:
			#velocity.y = 0
			jumping = false
			
		if (is_on_floor()):
			real_grav = 0
			$AnimatedSprite.playing = true
		elif (!attacking):
			$AnimatedSprite.playing = false
		
		if (attacking):
			#velocity.x = 0
			if (d > attack_range and d < reach):
				velocity.x = abs(position.x - player.position.x) * 1.5
				
				if (!facing_right):
					velocity.x *= -1
			else:
				velocity.x = 0
			
			
		else:
			$AnimatedSprite.animation = "Walk"
		
		move_and_slide(velocity, Vector2.UP)
		
			
			
func flip():
	if (flip_waiting or (dodgeable or hitting)):
		return
	if (!flip_tired):
		if (dodgeable or hitting):
			return
		flip_waiting = true
		
		yield(get_tree().create_timer(flip_delay), "timeout")
		if (dodgeable or hitting):
			flip_waiting = false
			return
			
		flip_waiting = false
		flip_tired = true
		var correction = 15
		
		$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
		facing_right = !facing_right
		$Collision_Left.disabled = facing_right
		$Collision_Right.disabled = !facing_right
		
		if (facing_right):
			teleport(Vector2(correction,0))
		else:
			teleport(Vector2(-correction,0))
			
		yield(get_tree().create_timer(flip_tired_delay), "timeout")
		
		flip_tired = false
		
func attack():
	if (is_on_floor()):
		velocity = Vector2()
	attacking = true
	charging = true
	attack_recovering = true
	
	$AnimatedSprite.play("Attack")
	#hurt.attck(facing_right, 1.5)
	
	
	yield(get_tree().create_timer(dodge_window), "timeout")
	dodgeable = true
	
	yield(get_tree().create_timer(real_attack_delay), "timeout")
	hitting = true
	charging = false
	dodgeable = false
	
	
	hurt.attck(facing_right)
		
	yield(get_tree().create_timer(real_attack_length), "timeout")
	attacking = false
	hitting = false
	#hurt.attck(facing_right)
	if (is_on_floor()):
		velocity = Vector2()
		
	yield(get_tree().create_timer(attack_recover_time), "timeout")
	attack_recovering = false
	
func teleport(t, rel=true):
	if rel:
		translate(t)
	else:
		position = t	

func set_player(p):
	player = p

func _on_Shoot_timeout():
	if (state == DEAD):
		return
	
	if state == SHOOTING:
		print("Shooting...")
		$AnimatedSprite.animation = "Shoot"
		yield(get_tree().create_timer(1.25), "timeout")
		if (state == DEAD):
			return
		if player:
			dir = (player.position - position).normalized()
			
			if (facing_right):
				$muzzle/right.add_child(bullet.instance())
			else:
				$muzzle/left.add_child(bullet.instance())
			
			
			yield(get_tree().create_timer(0.15), "timeout")
			
			if player:			
				$AnimatedSprite.animation = "Idle"

func _on_Timer_timeout():
	if (state == DEAD):
		return
	ray.cast_to = player.position - position
	
	if ray.get_collider() == player and position.distance_to(player.position) < RANGE:
		if (position.x < player.position.x and facing_right) or (position.x > player.position.x and !facing_right):
			if (ranged):
				state = SHOOTING
			elif (len(nav.get_simple_path(position, player.position)) > 1):
				state = CHASING
	else:
		forget()

func forget():
	if !waiting:
		waiting = true
		yield(get_tree().create_timer(forget_time), "timeout")
		waiting = false
		if !attacking:
			if a == null :
				state = IDLE
			else:
				state = PATR