extends Particles

const MAX_LIFETIME = 2

func _ready():
	emitting = Saved.save_data["particles"]

func update_particles(speed):
	lifetime = MAX_LIFETIME / ((speed / 2) + 0.01)

func manage_particles(value):
	emitting = value
	Saved.save_data["particles"] = value
	Saved.save_game()
