extends CharacterBody3D

@onready var sprite : AnimatedSprite3D = $AnimatedSprite3D

enum et {
	CLOSE,
	SHOOTING,
	EXPLODING
}

@export var move_speed : int
@export var attack_range : int
@export var sprite_texture : SpriteFrames = null 
@export var enemy_type : et;
@export var stun_time : int = 3

@onready var player : CharacterBody3D = get_tree().root.get_child(0).find_child("Player")
@onready var gc 
@onready var ray = $DetectPlayer

var player_in_range = false

var dead :bool = false
var stunned : bool = false
var kicked : bool = false
var firs_col : bool = true

func _ready():
	gc = get_tree().root.get_child(0)
	sprite.sprite_frames = sprite_texture
	$DetectPlayer.target_position = player.global_position
	sprite.play("walk")

func _physics_process(delta):
	if sprite.animation == "death" and sprite.frame == 5:
		sprite.position.y = move_toward(sprite.position.y, 0.445, 0.08)
		
	if stunned:
		if kicked && firs_col:
			kill()
			firs_col = false
	
	if dead:
		$CollisionShape3D.disabled = true
		return
	
	if player == null:
		return
	
	match enemy_type:
		et.CLOSE:
			if !kicked:
				closeRangeHandle()
		et.SHOOTING:
			pass
		et.EXPLODING:
			pass
	
	move_and_slide()

func playerInRange() -> bool :
	if ray.is_colliding() && ray.get_collider().name == "Player":
		sprite.play("walk")
		return true
	else:
		sprite.play("idle")
		return false

func closeRangeHandle():
	$DetectPlayer.target_position = player.global_position - global_position
	if playerInRange():
		var dir = player.global_position - global_position
		dir.y = 0
		dir = dir.normalized()
		velocity = dir * move_speed
	else:
		sprite.play("idle")
		velocity = Vector3.ZERO

func kill():
	$DetectBodies.monitoring = false
	gc.kill_count += 1
	sprite.play("death")
	$CollisionShape3D.disabled = true
	dead = true

func stun():
	if stunned:
		return
	#sprite.play(stunned)
	stunned = true
	await get_tree().create_timer(stun_time).timeout
	if $DetectBodies.get_overlapping_bodies().size() > 0:
		player.kill()
	stunned = false
	

func knockback(dir, force , kick_raycast_pos):
	kicked = true
	velocity = dir * force
	await get_tree().create_timer(0.3).timeout
	stun()
	kicked = false

func _on_detect_bodies_body_entered(body):
	if body.name == "Player" && !stunned or kicked:
		body.kill()
