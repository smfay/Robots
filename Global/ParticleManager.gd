extends Node2D
class_name ParticleManager

var hit_flash = preload("res://Assets/FX/HitFlash.tscn")
var run_dust = preload("res://Assets/FX/DustRun.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func create_effect(pos,effect):
	var fx = effect.instance()
	fx.global_position = pos
	GameManager.world.add_child(fx)
