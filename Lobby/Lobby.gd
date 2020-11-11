extends CanvasLayer

onready var NameTextbox = $VBoxContainer/CenterContainer/GridContainer/NameTextBox
onready var port = $VBoxContainer/CenterContainer/GridContainer/PortTextBox
onready var selected_IP = $VBoxContainer/CenterContainer/GridContainer/IPTextBox

var is_cop = false

func _ready():
	NameTextbox.text = Saved.save_data["Player_name"]
	selected_IP.text = Network.DEFAULT_IP
	port.text = str(Network.DEFAULT_PORT)


func _on_HostButton_pressed():
	Network.selected_port = int(port.text)
	Network.is_cop = is_cop
	Network.create_server()
	get_tree().call_group("HostOnly", "show")
	create_waiting_room()

func _on_JoinButton_pressed():
	Network.selected_port = int(port.text)
	Network.selected_IP = selected_IP.text
	Network.is_cop = is_cop
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
	


func _on_TeamCheck_toggled(button_pressed):
	is_cop = button_pressed


func _on_TeamCheck_item_selected(index):
	if not int(is_cop) == index:
		var button = $VBoxContainer/CenterContainer/GridContainer/TeamCheck
		button.set_item_disabled(0, true)
		button.set_item_disabled(1, true)
		is_cop = index
		$LobbyBackground.pivot()

func _on_Tween_tween_completed(object, key):
	var button = $VBoxContainer/CenterContainer/GridContainer/TeamCheck
	button.set_item_disabled(0, false)
	button.set_item_disabled(1, false)


func _on_ColorPickerButton_color_changed(color):
	$LobbyBackground.new_colour(color)
