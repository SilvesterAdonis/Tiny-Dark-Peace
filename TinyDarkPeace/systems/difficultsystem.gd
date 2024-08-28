extends  Node

@export var mobs_spawner: MobSpawner
@export var iniatial_spawn_rate: float = 60.0
@export var mobs_increase_per_minute: float = 30.0
@export var wave_duration: float = 20.0
@export var break_intensity: float = 0.5

var time: float = 0.0

func _process(delta: float) -> void:
	# Ignorar Game Over
	if GameManager.is_game_over: return
	
	# Incrementar temporizador
	time += delta
	
	# Dificuldade Linear
	var spaw_rate =  iniatial_spawn_rate + mobs_increase_per_minute * (time/ 60.0)
	# Sistema de ondas
	var wave = sin((time * TAU) / wave_duration)
	var wave_factor = remap(wave, -1.0, 1.0, break_intensity, 1)
	spaw_rate *= wave_factor
	
	mobs_spawner.frequencia = spaw_rate
	
	
	
