extends Area2D

var direction
var speed = 220
var revert = 1
var has_hit = false
var moving = 1
var DMG = 70

var mag

var col_count = 0
var max_col_count = 2

var rng = RandomNumberGenerator.new()

func _ready():
	
	#direction = (PlayerData.player.position - position).normalized()
	#$AnimatedSprite.animation = "start"
	#yield(get_tree().create_timer(0.415), "timeout")
	$AnimatedSprite.animation = "default"
	mag = rng.randi_range(30,60)
	
func _physics_process(delta):

	#var new_direction = (PlayerData.player.position - position).normalized()
	#direction -= (direction - new_direction) / 5
	
	#direction = direction.normalized()
	
	var x = speed * delta * revert
	var y = mag * sin(position.x / 30) * delta * 5
	
	position.x += x
	position.y += y
	
	speed += delta * moving * 2
	
	rotation_degrees = rad2deg(Vector2(x,y).angle())

func _on_Area2D_body_entered(body):
	print("Ball has hit:" + body.name)
	if body.is_in_group("barrier"):
		if (col_count < max_col_count):
			col_count += 1
			revert *= -1
			mag = rng.randi_range(30,60)
			has_hit = false
		else:
			speed = 0
			moving = 0
			#$AnimatedSprite.animation = "stop"
			has_hit = true
			
			#yield(get_tree().create_timer(1.25), "timeout")
			queue_free()
		
	if body == PlayerData.player and !has_hit:
		if (col_count < max_col_count):
			col_count += 1
			revert *= -1
			mag = rng.randi_range(30,60)
			has_hit = true
			body.damage(DMG)
			return 
			
		if (body.get_node("hurtbox") in get_overlapping_areas()):
			has_hit = true
		else:
			body.damage(DMG)
			has_hit = true

		
		
