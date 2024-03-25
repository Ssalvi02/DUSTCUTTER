extends CharacterBody3D

@onready var sprite = $AnimatedSprite3D

@export var move_speed = 2.0
@export var attack_range = 2.0

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

var dead = false

func _physics_process(delta):
	if sprite.animation == "death" and sprite.frame == 5:
		sprite.position.y = move_toward(sprite.position.y, 0.445, 0.08)
	if dead:
		$CollisionShape3D.disabled = true
		return
	
	if player == null:
		return
	
	var dir = player.global_position - global_position
	dir.y = 0
	dir = dir.normalized()
	
	velocity = dir * move_speed
	move_and_slide()

func kill():
	sprite.play("death")
	dead = true
	$CollisionShape3D.disabled = true
