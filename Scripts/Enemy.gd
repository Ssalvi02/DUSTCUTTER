extends CharacterBody3D

@onready var sprite : AnimatedSprite3D = $AnimatedSprite3D

enum et {
	CLOSE,
	SHOOTING,
	EXPLODING,
	STALKER
}

@export var move_speed : int = 0
@export var attack_range : int = 0
@export var sprite_texture : SpriteFrames = null 
@export var enemy_type : et;

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

var player_in_range = false

var dead = false

func _ready():
	sprite.sprite_frames = sprite_texture
	sprite.play("walk")

func _physics_process(delta):
	if sprite.animation == "death" and sprite.frame == 5:
		sprite.position.y = move_toward(sprite.position.y, 0.445, 0.08)
	if dead:
		$CollisionShape3D.disabled = true
		return
	
	if player == null:
		return
	
	match enemy_type:
		et.CLOSE:
			closeRangeHandle()
		et.SHOOTING:
			pass
		et.EXPLODING:
			pass
		et.STALKER:
			pass
	
	move_and_slide()

func playerInRange() -> bool :
	if player_in_range:
		sprite.play("walk")
		return true
	else:
		sprite.play("idle")
		return false

func closeRangeHandle():
	if playerInRange():
		var dir = player.global_position - global_position
		dir.y = 0
		dir = dir.normalized()
		velocity = dir * move_speed
	else:
		sprite.play("idle")
		velocity = Vector3.ZERO

func kill():
	sprite.play("death")
	dead = true
	$CollisionShape3D.disabled = true

func _on_sense_player_area_entered(area):
	if area.name == "PickupArea":
		player_in_range = true


func _on_sense_player_area_exited(area):
	if area.name == "PickupArea":
		player_in_range = false
