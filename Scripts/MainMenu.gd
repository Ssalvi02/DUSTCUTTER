extends Control

@onready var select = $Select

var active_select = -1
var labels = null

const loading_scene = "res://Scenes/UI/loading.tscn"

func _ready():
	labels = select.get_children()

func _physics_process(delta):
	match active_select:
		-1:
			unlerp_all()
		0: #Continue
			lerp_shadow(active_select)
		1: #New Game
			if(Input.is_action_just_pressed("select")):
				get_tree().change_scene_to_file(loading_scene)
			lerp_shadow(active_select)
		2: #Options
			lerp_shadow(active_select)
		3: #Quit
			lerp_shadow(active_select)
		4: #Quit
			lerp_shadow(active_select)
		_:
			unlerp_all()

func lerp_shadow(child):
	labels[child].label_settings.shadow_offset = labels[child].label_settings.shadow_offset.lerp(Vector2(3,3), 0.1)
	unlerp_all()


func unlerp_all():
	for i in labels:
		if i.get_index() != active_select:
			i.label_settings.shadow_offset = i.label_settings.shadow_offset.lerp(Vector2(0,0), 0.1)

func _on_continue_mouse_entered():
	active_select = 0

func _on_new_game_mouse_entered():
	active_select = 1

func _on_options_mouse_entered():
	active_select = 2

func _on_credits_mouse_entered():
	active_select = 3
	
func _on_quit_mouse_entered():
	active_select = 4

func _on_continue_mouse_exited():
	active_select = -1
	
func _on_new_game_mouse_exited():
	active_select = -1

func _on_options_mouse_exited():
	active_select = -1

func _on_quit_mouse_exited():
	active_select = -1

func _on_credits_mouse_exited():
	active_select = -1

func _on_quit_gui_input(event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		get_tree().quit()
