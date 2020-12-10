extends VehicleBody

const MAX_STEER_ANGLE = 0.35
const STEER_SPEED = 1

const MAX_ENGINE_FORCE = 175
const MAX_BRAKE_FORCE = 10
const MAX_SPEED = 25

var steer_target = 0.0 # where do I want the wheels to go?
var steer_angle = 0.0 # where are the wheels now

var paint_colour = Color(1,1,0)    # Default yellow colour for testing

var money = 0
var money_drop = 50
var money_per_beacon = 1000

export var max_arrest_value = 1000
var arrest_value = 0
var criminal_detected = false

var siren = false

sync var players = {}
var player_data = {"steer": 0, "engine": 0, "brakes": 0, 
		"position": null, "speed": 0, "money": 0, "siren": false}

func _ready():
	join_team()
	label_car()
	paint_car()
	players[name] = player_data
	players[name].position = transform
	if not is_local_Player():
		$Camera.queue_free()
		$GUI.queue_free()

func _physics_process(delta):
	if is_local_Player():
		drive(delta)
		display_location()
	
	if not Network.local_player_id == 1:
		transform = players[name].position
	
	steering = players[name].steer
	engine_force = players[name].engine
	brake = players[name].brakes
	
	if is_in_group("cops"):
		check_siren()
	
	if criminal_detected:
		increment_arrest_value()

func is_local_Player():
	return name == str(Network.local_player_id)

func join_team():
	paint_colour = Network.players[int(name)]["paint_colour"]
	print("join_team, id: " + name)
	if Network.players[int(name)]["is_cop"]:
		add_to_group("cops")
		collision_layer = 4
		$RobberMesh.queue_free()
		$CopMesh.name = "CarBody"
	else:
		$CopMesh.queue_free()
		$Arrow.queue_free()
		$Siren.queue_free()
		$RobberMesh.name = "CarBody"

func label_car():
	if is_local_Player():
		$PlayerBillboard/Viewport/PlayerLabel.queue_free()
	else:
		$PlayerBillboard/Viewport/TextureProgress.max_value = max_arrest_value
		$PlayerBillboard/Viewport/PlayerLabel.text = Network.players[int(name)]["Player_name"]

func paint_car():
	var paint = SpatialMaterial.new()
	paint.metallic = 0.75
	paint.metallic_specular = 0.25
	paint.roughness = 0.25
	paint.albedo_color = paint_colour
	$CarBody.set_surface_material(0, paint)

func drive(delta):
	var speed = players[name].speed
	var steering_value = apply_steering(delta)
	var throttle = apply_throttle(speed)
	var brakes = apply_brakes()
	update_server(name, steering_value, throttle, brakes, speed)


func apply_steering(delta):
	var steer_val = 0
	var left = Input.get_action_strength("steer_left")
	var right = Input.get_action_strength("steer_right")
	
	if left:
		steer_val = left
	elif right:
		steer_val = -right
	
	steer_target = steer_val
	
	if steer_target < steer_angle:
		steer_angle -= STEER_SPEED * delta
	elif steer_target > steer_angle:
		steer_angle += STEER_SPEED * delta
	
	return steer_angle

func apply_throttle(speed):
	var throttle_val = 0
	var forward = Input.get_action_strength("forward")
	var back = Input.get_action_strength("back")
	
	if speed < MAX_SPEED:
		if back:
			throttle_val = -back
		elif forward:
			throttle_val = forward
	
	return throttle_val * MAX_ENGINE_FORCE

func apply_brakes():
	var brake_val = 0
	var brake_strength = Input.get_action_strength("brake")
	
	if brake_strength:
		brake_val = brake_strength
	
	return brake_val * MAX_BRAKE_FORCE

func update_server(id, steering_value, throttle, brakes, speed):
	if not Network.local_player_id == 1:
		rpc_unreliable_id(1, "manage_clients", id, steering_value, throttle, brakes, speed)
	else:
		manage_clients(id, steering_value, throttle, brakes, speed)
	get_tree().call_group("Interface", "update_speed", speed)
	$Exhaust.update_particles(speed)

sync func manage_clients(id, steering_value, throttle, brakes, speed):
	players[id].steer = steering_value
	players[id].engine = throttle
	players[id].brakes = brakes
	players[id].position = transform
	players[id].speed = linear_velocity.length()
	rset_unreliable("players", players)

func display_location():
	var x = stepify(translation.x, 1)
	var z = stepify(translation.z, 1)
	$GUI/ColorRect/VBoxContainer/Location.text = str(x) + " , " + str(z)

func beacon_emptied():
	money += money_per_beacon
	manage_money()

func manage_money():
	if Network.local_player_id == 1:
		update_money(name, money)
	else:
		rpc_id(1, "update_money", name, money)
	
remote func update_money(id, cash):
	players[id].money = cash
	if name == "1":
		display_money(cash)
	else:
		rpc_id(int(id), "display_money", cash)

remote func display_money(cash):
	money = players[name].money
	$GUI/ColorRect/VBoxContainer/MoneyLabel/AnimationPlayer.play("MoneyPulse")
	$GUI/ColorRect/VBoxContainer/MoneyLabel.text = "£" + str(cash)

func money_delivered():
	get_tree().call_group("Announcements", "money_stashed", Saved.save_data["Player_name"], money)
	get_tree().call_group("gamestate", "update_gamestate", money, 0)
	money = 0
	manage_money()

func _on_Player_body_entered(body):
	if body.has_node("Money"):
		body.queue_free()
		money += money_drop
		if is_in_group("cops"):
			get_tree().call_group("gamestate", "update_gamestate", 0, money)
	elif money > 0 and not is_in_group("cops"):
		spawn_money()
		money -= money_drop
	manage_money()

func spawn_money():
	var moneybag = preload("res://Props/MoneyBag/MoneyBag.tscn").instance()
	moneybag.translation = Vector3(translation.x, 4, translation.z)
	get_parent().get_parent().add_child(moneybag)

func _input(event):
	if event.is_action_pressed("car_sound") and is_local_Player() and is_in_group("cops"):
		siren = !siren
		if not Network.local_player_id == 1:
			rpc_id(1, "toggle_siren", name, siren)
		else:
			toggle_siren(name, siren)

func toggle_siren(id, siren_state):
	players[id]["siren"] = siren_state

func check_siren():
	if siren:
		$Siren/ArrestArea.monitoring = true
		if not $Siren/AudioStreamPlayer3D.playing:
			$Siren/AudioStreamPlayer3D.play()
		$Siren/SirenMesh/SpotLight.show()
		$Siren/SirenMesh/SpotLight2.show()
	else:
		$Siren/ArrestArea.monitoring = false
		$Siren/AudioStreamPlayer3D.stop()
		$Siren/SirenMesh/SpotLight.hide()
		$Siren/SirenMesh/SpotLight2.hide()

func _on_ArrestArea_body_entered(body):
	body.criminal_detected = true

func _on_ArrestArea_body_exited(body):
	body.criminal_detected = false
	
func increment_arrest_value():
	arrest_value += 1
	$PlayerBillboard/Viewport/TextureProgress.value = arrest_value
	if arrest_value == max_arrest_value:
		get_tree().call_group("Announcements", "victory", false)
