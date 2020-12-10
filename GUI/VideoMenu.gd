extends Popup


func _ready():
	$VBoxContainer/CenterContainer/GridContainer/DOFCheck.pressed = Saved.save_data["dof"]
	$VBoxContainer/CenterContainer/GridContainer/ReflectionsCheck.pressed = Saved.save_data["reflections"]
	$VBoxContainer/CenterContainer/GridContainer/FogCheck.pressed = Saved.save_data["fog"]
	$VBoxContainer/CenterContainer/GridContainer/ParticlesCheck.pressed = Saved.save_data["particles"]
	$VBoxContainer/CenterContainer/GridContainer/FarCheck.pressed = Saved.save_data["far_cam"]

func _on_DoneButton_pressed():
	hide()

func _on_DOFCheck_toggled(button_pressed):
	get_tree().call_group("Cameras", "dof", button_pressed)

func _on_ReflectionsCheck_toggled(button_pressed):
	get_tree().call_group("Cameras", "reflections", button_pressed)

func _on_FogCheck_toggled(button_pressed):
	get_tree().call_group("Cameras", "fog", button_pressed)

func _on_ParticlesCheck_toggled(button_pressed):
	get_tree().call_group("Particles", "manage_particles", button_pressed)

func _on_FarCheck_toggled(button_pressed):
	get_tree().call_group("Cameras", "far_cam", button_pressed)
