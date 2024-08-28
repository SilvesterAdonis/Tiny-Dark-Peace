extends Node

@export var speed: float = 1.8

var enemy: Enemy
var animationsprite2d:AnimatedSprite2D
var input_vector


func _ready() -> void:
	enemy = get_parent()
	animationsprite2d = enemy.get_node("AnimatedSprite2D")
# -------------------------------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	# Ignorar Game Over
	if GameManager.is_game_over: return
	
	# Calcular a posição
	
	# (posição.player - posição.inimgo)N
	var player_position = GameManager.player_position
	var difference = player_position - enemy.position
	input_vector = difference.normalized()
	# input_vector = vector2 que varia entre -1 e 1
	# Movimento
	enemy.velocity = input_vector * speed * 100.0
	enemy.move_and_slide()
	rotate_sprite()
# -------------------------------------------------------------------------------------------------------
func rotate_sprite() -> void:
	# Girar Sprite
	if input_vector.x > 0:
		# Desmarcar flip_h do Sprite 2D
		animationsprite2d.flip_h = false
	elif input_vector.x < 0:
		# Marcar flip_h do Sprite 2D
		animationsprite2d.flip_h = true
# -------------------------------------------------------------------------------------------------------
