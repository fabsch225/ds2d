extends KinematicBody2D

export var a = 0
export var b = 0
export var at_b = -1 #true

var s = 0

func _ready():
	set_physics_process(false) 

func _physics_process(delta):
	var y = position.y
	s = min(abs(y - a), abs(y - b)) + 5
	s *= at_b
	if (at_b == -1 and abs(y - a) < 2) or (at_b == 1 and abs(y - b) < 2):
		stop()
	
	position.y += s * delta
	#move_and_slide(Vector2(0,s))
	
func start():
	print("Starting Elevator")
	if $Area2D.overlaps_body(PlayerData.player):
		PlayerData.player.on_elevator = true
		
		get_tree().call_group("eld", "open")
		
		PlayerData.player.current_elevator = self
		PlayerData.player.set_physics_process(false) 
	set_physics_process(true) 

func stop():
	at_b *= -1
	if $Area2D.overlaps_body(PlayerData.player):
		PlayerData.player.on_elevator = false
		
		get_tree().call_group("eld", "close")
		PlayerData.player.set_physics_process(true) 
	set_physics_process(false) 
	sync_position()

func sync_position():
	if (at_b == -1):
		position.y = b
	else:
		position.y = a

func _on_Area2D_body_entered(body):
	if (body == PlayerData.player):
		Hud.use_elevator.display(self)
		print("Display Menu")

func _on_Area2D_body_exited(body):
	if (body == PlayerData.player):
		Hud.use_elevator.stop()
		if PlayerData.player.on_elevator:
			PlayerData.player.on_elevator = false
			
