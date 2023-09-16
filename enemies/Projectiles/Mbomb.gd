extends KinematicBody2D

onready var cast = $RayCast2D
onready var area = $Area2D

var direction
var speed = 250
var G = 4
var down_force = 0
var facing_right = false
var right = 1

var DMG = 45


func _ready():
	
	#if get_parent().dir != null:
	#direction = get_parent().get_parent().get_parent().dir
	#facing_right = get_parent().get_parent().get_parent().facing_right
	#if (!facing_right):
		#right = -1
	
	#print(direction	)
	pass

func _physics_process(delta):

	rotation_degrees += 360 / 1 / 60 * right * (speed / 200) * 0.9
	
	down_force += G
	speed -= 50 * delta

	move_and_slide(direction * speed,Vector2.UP)
	move_and_slide(Vector2(0,down_force	),Vector2.UP)

	if (is_on_floor()):
		print("bounce")
		down_force = -speed + speed * (((randi()%20-10)/20))



func _on_Area2D_body_entered(body):
	if body == PlayerData.player:
		explode()


func explode():
	
	set_process(false)
	set_physics_process(false)
	rotation_degrees = 0
	
	
	
	$AnimatedSprite.animation = "stop"
	
	yield(get_tree().create_timer(0.625), "timeout")
	if PlayerData.player in $Explosion.get_overlapping_bodies():
		PlayerData.player.damage(DMG)
	yield(get_tree().create_timer(0.625), "timeout")
	
	queue_free()


func _on_Timer_timeout():
	explode()
