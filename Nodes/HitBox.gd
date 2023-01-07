class_name HitBox, "res://Icons/icon4.png"
extends Area2D

export var grab := false
export var damage := 10
var angle = Vector2.ZERO
onready var base_knockback = 300

func _init() -> void:
	collision_layer = 2
	collision_mask = 0
