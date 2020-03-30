extends Control

onready var NameTextbox = $VBoxContainer/CenterContainer/GridContainer/NameTextBox
onready var port = $VBoxContainer/CenterContainer/GridContainer/PortTextBox
onready var selected_IP = $VBoxContainer/CenterContainer/GridContainer/IPTextBox

func _ready():
	NameTextbox.text = Saved.save_data["Player_name"]
	selected_IP.text = Network.DEFAULT_IP
	port.text = str(Network.DEFAULT_PORT)

func _on_HostButton_pressed():
	Network.selected_port = int(port.text)
	Network.create_server()
	get_tree().call_group("HostOnly", "show")
	create_waiting_room()

func _on_JoinButton_pressed():
	Network.selected_port = int(port.text)
	Network.selected_IP = selected_IP.text
	Network.connect_to_server()
	create_waiting_room()

func _on_NameTextBox_text_changed(new_text):
	Saved.save_data["Player_name"] = NameTextbox.text
	Saved.save_game()

func create_waiting_room():
	$WaitingRoom.popup_centered()
	$WaitingRoom.refresh_players(Network.players)

func _on_ReadyButton_pressed():
	Network.start_game()
	
