extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var tolerance = 2
var input_tolerance = 0.5
var current_block
var target_block
var camera
var is_moving = false;
var can_move = false;
var movement_speed = 10
var speed_normalization = 0


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	$Player.transform.origin = $"../LevelOrigin/StartBlock".transform.origin
	current_block = $"../LevelOrigin/StartBlock"
	camera = $"../CameraOrigin/CameraRotationY/CameraRotationX/Camera"
	
	pass

func _input(event):
	if(event.is_action_pressed("ui_down")):
		var avaliable_blocks = get_avaliable_blocks()
		print("Avaliable blocks:" )
		for block in avaliable_blocks:
			print(block.transform.origin)
			
	pass
	
	
func check_distance(b1, b2):
	var block_distance = camera.unproject_position(b1.transform.origin) - camera.unproject_position(b2.transform.origin)
	var max_distance_x = camera.unproject_position(Vector3(0,0,0)) - camera.unproject_position(Vector3(2,0,0))
	var max_distance_z = camera.unproject_position(Vector3(0,0,0)) - camera.unproject_position(Vector3(0,0,2))
	if(abs(block_distance.normalized().dot(max_distance_x.normalized()))> abs(block_distance.normalized().dot(max_distance_z.normalized()))):
		return abs(max_distance_x.length() - block_distance.length()) <= tolerance
	else:
		return abs(max_distance_z.length() - block_distance.length()) <= tolerance
		
func get_avaliable_blocks():
	var avaliable_blocks = []
	var blocks = get_tree().get_nodes_in_group("Block")
	for block in blocks:
		if(block!=current_block):
			if(check_distance(block, current_block)):
				print(block)
				avaliable_blocks.append(block)
		
	return avaliable_blocks

func _process(delta):
	
	var movement_direction = Vector2(Input.get_joy_axis(1,0),Input.get_joy_axis(1,1))
	
	if (Input.is_action_pressed("ui_up")):
		movement_direction += Vector2(0,-1)
	if (Input.is_action_pressed("ui_down")):
		movement_direction += Vector2(0,1)
	if (Input.is_action_pressed("ui_left")):
		movement_direction += Vector2(-1,0)
	if (Input.is_action_pressed("ui_right")):
		movement_direction += Vector2(1,0)
	
	
	if is_moving:
		var animation_direction = target_block.transform.origin - $Player.transform.origin
		speed_normalization = animation_direction.length()
		$Player.transform.origin.x = $Player.transform.origin.x + animation_direction.normalized().x*movement_speed*speed_normalization*delta
		$Player.transform.origin.y = $Player.transform.origin.y + animation_direction.normalized().y*movement_speed*speed_normalization*delta
		$Player.transform.origin.z = $Player.transform.origin.z + animation_direction.normalized().z*movement_speed*speed_normalization*delta
		var projection_origin = Vector2($Player.transform.origin.x, $Player.transform.origin.z)
		var projection_target = Vector2(target_block.transform.origin.x, target_block.transform.origin.z)
		if((projection_origin - projection_target).length() < 0.2):
			
			$Player.global_transform.origin = target_block.global_transform.origin
			$Player/MeshInstance.get_surface_material(0).set("flags_no_depth_test", false)
			current_block = target_block
			target_block = null
			is_moving = false;
			print("done")
			
		return

	else:
		
		if movement_direction.length() > input_tolerance:
			
			var avaliable_blocks = get_avaliable_blocks()
			if len(avaliable_blocks) == 0:
				print("can't move")
				return
#			if not can_move:
#				print("cant move")
#				return 
				
				
			print("Start movement")
			var next_avaliable_block = avaliable_blocks[0]
			var next_avaliable_angle = -1
			for block in avaliable_blocks:
				var block_direction= camera.unproject_position(block.transform.origin) - camera.unproject_position(current_block.transform.origin)
				print("checking block..")
				print(block_direction.normalized())
				print(movement_direction.normalized())
				var block_angle = block_direction.normalized().dot(movement_direction.normalized())
				if block_angle  >  next_avaliable_angle:
					next_avaliable_angle = block_angle
					next_avaliable_block = block
					
					
			if next_avaliable_angle < 0.5:
				print("Can't move")
				return
					
			target_block = next_avaliable_block
			if(target_block.transform.origin.y != current_block.transform.origin.y):
				$Player/MeshInstance.get_surface_material(0).set("flags_no_depth_test",true)
			print("moving to" + str(target_block.transform.origin))
			is_moving = true
			can_move = false
			return
		
		
	if movement_direction.length() < 0.7:
		can_move = true
		
		
			
	