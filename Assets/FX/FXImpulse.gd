extends Particles2D
class_name ImpulseEffect

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	modulate = Color(1,1,1,2)
	emitting = true


func _process(delta):
	if !emitting:
		queue_free()
