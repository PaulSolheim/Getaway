extends Node

const MASTER_BUS = 0
const SFX_BUS = 1
const MUSIC_BUS = 2

func _ready():
	var master_volume = Saved.save_data["master_volume"]
	var sfx_volume = Saved.save_data["sfx_volume"]
	var music_volume = Saved.save_data["music_volume"]
	
	AudioServer.set_bus_volume_db(MASTER_BUS, master_volume)
	AudioServer.set_bus_volume_db(SFX_BUS, sfx_volume)
	AudioServer.set_bus_volume_db(MUSIC_BUS, music_volume)

func update_master_volume(new_volume):
	AudioServer.set_bus_volume_db(MASTER_BUS, new_volume)
	Saved.save_data["master_volume"] = new_volume
	Saved.save_game()

func update_sfx_volume(new_volume):
	AudioServer.set_bus_volume_db(SFX_BUS, new_volume)
	Saved.save_data["sfx_volume"] = new_volume
	Saved.save_game()

func update_music_volume(new_volume):
	AudioServer.set_bus_volume_db(MUSIC_BUS, new_volume)
	Saved.save_data["music_volume"] = new_volume
	Saved.save_game()


	
	
	


