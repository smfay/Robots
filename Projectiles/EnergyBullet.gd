extends KinematicBody2D

var velocity = Vector2.ZERO
var speed = 200

var direction = Vector2.ZERO
onready var damage = $HitBox
onready var hitbox = $HitBox/CollisionShape2D
onready var wallbox = $Area2D/CollisionShape2D
var death_effect := preload("res://Assets/FX/ExplodeBullet.tscn")
var player = null
var parent = instance_from_id(get_instance_id())


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	damage.base_knockback = speed
	wallbox.disabled = true
	player = get_tree().current_scene.find_node("Player")

func _process(delta):
	velocity = move_and_slide(velocity)


func _on_Timer_timeout():
	wallbox.disabled = false
	
func die():
	var effect := death_effect.instance()
	effect.global_position = global_position
	get_tree().current_scene.add_child(effect)
	queue_free()

func _on_Area2D_body_entered(body):
	if body != parent:
		die()
	
func take_damage(hitbox, amount: int, angle: Vector2, base_knockback: int) -> void:
	if hitbox.owner.is_in_group("Player"):
			velocity = angle * (speed * 2.5)
			parent = instance_from_id(hitbox.owner.get_instance_id())
