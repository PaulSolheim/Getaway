extends Spatial

var cop_spawn

func _enter_tree():
	get_tree().set_pause(true)

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
			print("Key: " + str(key))
			spawn_remote_player(key)

func _on_ObjectSpawner_cop_spawn(location):
	cop_spawn = location
	
