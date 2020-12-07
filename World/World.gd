extends Spatial

var cop_spawn

var money_stashed = 0
var money_recovered = 0
export var criminal_victory_score = 3000
export var cop_victory_score = 3000

func _enter_tree():
	get_tree().set_pause(true)

func _input(event):
	if Input.is_action_just_pressed("menu"):
		$AudioMenu.visible = !$AudioMenu.visible

func _ready():
	pass

func spawn_local_player():
	var new_player = preload("res://Player/Player.tscn").instance()
	new_player.name = str(Network.local_player_id)
	print("spawn local: " + str(Network.local_player_id))
	new_player.translation = Vector3(6, 3, 13)
	$Players.add_child(new_player)
	if Network.is_cop:
		yield(get_tree(), "idle_frame")
		new_player.translation = cop_spawn

remote func spawn_remote_player(id):
	var new_player = preload("res://Player/Player.tscn").instance()
	new_player.name = str(id)
	print("spawn remote: " + str(id))
	new_player.translation = Vector3(6, 3, 13)
	$Players.add_child(new_player)
	if new_player.is_in_group("cops"):
		yield(get_tree(), "idle_frame")
		new_player.translation = cop_spawn

func unpause():
	get_tree().set_pause(false)
	spawn_local_player()
	# rpc("spawn_remote_player", Network.local_player_id)
	for key in Network.players.keys():
		if (key != Network.local_player_id):
			spawn_remote_player(key)
	if Network.environment == "res://Environments/night.tres":
		$Sun.queue_free()
	else:
		get_tree().call_group("lights", "queue_free")


func _on_ObjectSpawner_cop_spawn(location):
	cop_spawn = location
	
remote func update_gamestate(stashed, recovered):
	if Network.local_player_id == 1:
		money_stashed += stashed
		money_recovered += recovered
		check_win_conditions()
	else:
		rpc_id(1, "update_gamestate", stashed, recovered)

func check_win_conditions():
	if money_stashed >= criminal_victory_score:
		get_tree().call_group("Announcements", "victory", true)
	elif money_recovered >= cop_victory_score:
		get_tree().call_group("Announcements", "victory", false)
