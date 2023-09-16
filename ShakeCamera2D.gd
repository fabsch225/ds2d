extends Camera2D

onready var noise = OpenSimplexNoise.new()

var noise_y = 0

export var decay = 0.8  # How quickly the shaking stops [0, 1].

export var max_offset = Vector2(100, 75)  # Maximum hor/ver shake in pixels.

export var max_roll = 0.1  # Maximum rotation in radians (use sparingly).

var use_noise = false

export (NodePath) var target  # Assign the node this camera will follow.


var trauma = 0.0  # Current shake strength.

var trauma_power = 2  # Trauma exponent. Use [2, 3].


func _ready():
	randomize()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2

func add_trauma(amount, un=false):
	trauma = min(trauma + amount, 1.0)
	use_noise = un
	
func _process(delta):
	if target:
		global_position = get_node(target).global_position
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
		
func shake():
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * rand_range(-1, 1)
	offset.x = max_offset.x * amount * rand_range(-1, 1)
	offset.y = max_offset.y * amount * rand_range(-1, 1)

func shake_noise():
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * rand_range(-1, 1)
	offset.x = max_offset.x * amount * rand_range(-1, 1)
	offset.y = max_offset.y * amount * rand_range(-1, 1)
