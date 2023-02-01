extends Node2D


var player
var target = Vector2.ZERO
export var player_preference = 4
export var adapt_speed = 200.0
export var zoom_speed = 200.0
onready var vision_area = $Area2D
onready var cam = $Camera2D
var x_lerp = 0.0
var y_lerp = 0.0
var zoom = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	yield(GameManager,"ready")
	yield(GameManager.world,"ready")
	player = GameManager.world.player


func _physics_process(delta):
	if GameManager.world.player != null:
		vision_area.global_position = GameManager.world.player.global_position
	var collisions = vision_area.get_overlapping_bodies()
	if collisions:
		var x_avg = 0
		var y_avg = 0
		for body in collisions:
			x_avg += body.global_position.x
			y_avg += body.global_position.y
		x_lerp = move_toward(x_lerp,x_avg / collisions.size(),adapt_speed*delta)
		y_lerp = move_toward(y_lerp,y_avg / collisions.size(),adapt_speed*delta)
		target.x = ( x_lerp + (GameManager.world.player.global_position.x * (player_preference)) ) / (player_preference + 1)
		target.y = ( y_lerp + (GameManager.world.player.global_position.y * (player_preference)) ) / (player_preference + 1)
		if collisions.size() <= 1:
			zoom = lerp(zoom,1, zoom_speed*delta)
		else:
			zoom = lerp(zoom,clamp(GameManager.world.player.global_position.distance_to(target) * 0.0001,0.8,1.0), zoom_speed*delta)
			
	elif GameManager.world.player != null:
		target = GameManager.world.player.global_position
		zoom = move_toward(zoom,1, zoom_speed*delta)
	global_position.x = target.x
	global_position.y = target.y
	#global_position.x = move_toward(global_position.x,target.x,adapt_speed*delta)
	#global_position.y = move_toward(global_position.y,target.y,adapt_speed*delta)
	
	zoom = clamp(zoom,0.5,1.0)
	cam.set_zoom(Vector2(zoom,zoom))

