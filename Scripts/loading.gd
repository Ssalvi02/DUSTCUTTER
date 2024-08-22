extends Control

const target_scene = "res://Scenes/Levels/Level1.tscn"

var loading_status : int
var progress : Array[float]

@onready var prog_bar : TextureProgressBar = $TextureProgressBar

func _ready() -> void:
	ResourceLoader.load_threaded_request(target_scene)
	
func _process(_delta: float) -> void:
	loading_status = ResourceLoader.load_threaded_get_status(target_scene, progress)
	
	match loading_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			prog_bar.value = progress[0] * 100
		ResourceLoader.THREAD_LOAD_LOADED:
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(target_scene))
		ResourceLoader.THREAD_LOAD_FAILED:
			print("Error. Could not load Resource")
