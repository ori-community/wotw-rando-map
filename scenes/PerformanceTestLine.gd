extends Line2D


var last_point: Vector2 = Vector2.ZERO
var noise: FastNoiseLite = null
var time: float = 0.0


func _ready() -> void:
	noise = FastNoiseLite.new()
	
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	noise.frequency = 1.0
	noise.seed = rng.randi()


func _process(delta: float) -> void:
	time += delta
	last_point.x += noise.get_noise_1d(time) * 200.0 * delta
	last_point.y += noise.get_noise_1d(time + 200.0) * 200.0 * delta
	add_point(last_point)
