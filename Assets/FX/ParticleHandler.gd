extends Node2D


onready var run_dust_effect := preload("res://Assets/FX/DustRun.tscn")
onready var jump_dust_effect := preload("res://Assets/FX/DustJump.tscn")
onready var knockback_effect := preload("res://Assets/FX/DustJump.tscn")
onready var hit_wall := preload("res://Assets/FX/ExplodeBullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func dust():
	effect(run_dust_effect)
	
func jump():
	effect(jump_dust_effect)
	
func knockback():
	effect(run_dust_effect)
	
func hit_wall():
	effect(hit_wall)


func effect(effect):
	var fx = effect.instance()
	fx.global_position = global_position
	get_tree().current_scene.add_child(fx)
