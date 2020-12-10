extends Node

var save_data = {}
const SAVEGAME = "user://Savegame.json"

func _ready():
	save_data = get_data()

func get_data():
	var file = File.new()
	if not file.file_exists(SAVEGAME):
		save_data = {"Player_name": "Unnamed",
					 "local_paint_colour": "ff6e2626",
					 "master_volume": -10,
					 "sfx_volume": -10,
					 "music_volume": -10,
					 "dof": false,
					 "reflections": false,
					 "fog": false,
					 "particles": false,
					 "far_cam": false}
		save_game()
	file.open(SAVEGAME, File.READ)
	var content = file.get_as_text()
	var data = parse_json(content)
	save_data = data
	file.close()
	return(data)

func save_game():
	var save_game = File.new()
	save_game.open(SAVEGAME, File.WRITE)
	save_game.store_line(to_json(save_data))

