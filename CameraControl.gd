extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"


var camera_movement = Vector2()
var camera_speed = 2;

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass
	
func _input(event):
	if event is InputEventMouseMotion:
		camera_movement.x = -event.relative.y
		camera_movement.y = -event.relative.x
		camera_movement *= 0.05
		

func _process(delta):
	
	camera_movement.x += Input.get_joy_axis(1,4)
	camera_movement.y += Input.get_joy_axis(1,3)

	
	
	var speed = camera_speed
	if(Input.is_action_pressed("camera_speed")):
		speed = speed*0.2
	if(camera_movement.length() > 0.1):
		camera_movement = camera_movement*speed
		$CameraRotationY.rotate_y(camera_movement.y*delta)
		$CameraRotationY/CameraRotationX.rotate_x(camera_movement.x*delta)
		$CameraRotationY/CameraRotationX.rotation_degrees.x = clamp($CameraRotationY/CameraRotationX.rotation_degrees.x,-60,60)
	camera_movement = Vector2()