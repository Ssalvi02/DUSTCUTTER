extends Camera3D

@export var trauma_reduction_rate : float = 1.0

@export var max_x : float = 10.0
@export var max_y : float = 10.0
@export var max_z : float = 5.0

@export var noise : FastNoiseLite = FastNoiseLite.new()
@export var noise_speed : float = 50.0

var trauma : float = 0.0

var time : float = 0.0

@onready var initial_rotation : Vector3 = rotation_degrees 

func _process(delta):
	time += delta
	trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
	
	rotation_degrees.y = initial_rotation.y + max_y * get_shake_intensity() * get_noise_from_seed(1)
	rotation_degrees.z = initial_rotation.z + max_z * get_shake_intensity() * get_noise_from_seed(2)

func add_trauma(trauma_amount : float):
	trauma = clamp(trauma + trauma_amount, 0.0, 1.0)

func get_shake_intensity() -> float:
	return trauma * trauma

func get_noise_from_seed(_seed : int) -> float:
	noise.set_seed(_seed)
	return noise.get_noise_1d(time * noise_speed)
