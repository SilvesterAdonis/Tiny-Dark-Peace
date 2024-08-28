class_name Player
# -------------------------------------------------------------------------------------------------------
extends CharacterBody2D
# -------------------------------------------------------------------------------------------------------
@export_category("Movement")
@export var speed: float = 3
@export_category("Sword")
@export var sword_damage: int = 2
@export var sword_down: int = 8
@export_category("Health")
@export var health: int = 10
@export var max_health: int = 100
@export_category("Death")
@export var death_prefab:PackedScene
@export var hitbox_cooldown: float = 0.0
@export_category("Magic")
@export var ritual_damage: int = 25 
@export var ritual_interval: float = 30.0
@export var ritual_scene: PackedScene
# -------------------------------------------------------------------------------------------------------
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite2d: Sprite2D = $Sprite2D
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox: Area2D = $HitBox
@onready var healthprogress: ProgressBar = $HealthProgressBar
# -------------------------------------------------------------------------------------------------------
var input_vector: Vector2 = Vector2(0,0)
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var ritual_cooldown: float = 0.0
# -------------------------------------------------------------------------------------------------------
signal meat_collected(value: int)
# -------------------------------------------------------------------------------------------------------
func _ready():
	GameManager.player = self
	meat_collected.connect(func(value: int): 
		GameManager.meat_counter += 1)
# -------------------------------------------------------------------------------------------------------
func _process(delta) -> void:
	# Definir a posição do player para os enemies
	GameManager.player_position = position
	# Ler Input
	read_input()
	
	# Processar ataque
	update_attack_cooldown(delta)
	# Sistema de Ataque
	if Input.is_action_just_pressed("attack"):
		attack()
	if Input.is_action_just_pressed("attack_2x"):
		attack_dual()
	if Input.is_action_just_pressed("attack_up"):
		attack_up()
	if Input.is_action_just_pressed("attack_down"):
		attack_down()
	# Processar animação e rotação do sprite
	play_run_idle_animation()
	if not is_attacking:
		rotate_sprite()
	
	# Processar dano
	udpate_hitbox_detection(delta)
	
	# Processar ritual
	udpate_ritual(delta)
	
	# Atualizar health bar
	healthprogress.max_value = max_health
	healthprogress.value = health
# -------------------------------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	# Modificar a velocidade
	var target_velocity = input_vector * speed * 100.0
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity,target_velocity, 0.08)
	move_and_slide()
# -------------------------------------------------------------------------------------------------------
func read_input() -> void:
	# Obter o input_vector
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down") # deadzone = 0.15
	
	# Apagar deadzone do input_vector
	var deadzone = 0.15
	if abs(input_vector.x) < deadzone:
		input_vector.x = 0.0
		
	if abs(input_vector.y) < deadzone:
		input_vector.y = 0.0
		
	# Atualizar o is_running
	was_running = is_running 
	is_running = not input_vector.is_zero_approx()
# -------------------------------------------------------------------------------------------------------
func update_attack_cooldown(delta: float) -> void:
	# Atualizar temporizador do ataque
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")
# -------------------------------------------------------------------------------------------------------
func play_run_idle_animation() -> void:
	
		# Tocar a animação
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")
# -------------------------------------------------------------------------------------------------------
func rotate_sprite() -> void:
	# Girar Sprite
	if input_vector.x > 0:
		# Desmarcar flip_h do Sprite 2D
		sprite2d.flip_h = false
	elif input_vector.x < 0:
		# Marcar flip_h do Sprite 2D
		sprite2d.flip_h = true
# -------------------------------------------------------------------------------------------------------
func attack() -> void:
	
	if is_attacking:
		return
	# attack_side 1
	animation_player.play("attack_side_1")
	# Configurar temporizador
	attack_cooldown = 0.6
	# Marcar o ataque
	is_attacking = true 
# -------------------------------------------------------------------------------------------------------
func attack_dual() -> void:
	if is_attacking: return
	# attack_side 2
	animation_player.play("attack_side_2")
	# Configurar temporizador
	attack_cooldown = 0.6
	# Marcar o ataque
	is_attacking = true 
# -------------------------------------------------------------------------------------------------------
func attack_up() -> void:
	if is_attacking: return
	# attack_up_1
	animation_player.play("attack_up_1")
	# Configurar temporizador
	attack_cooldown = 0.6
	# Marcar o ataque
	is_attacking = true 
# -------------------------------------------------------------------------------------------------------
func attack_down() -> void:
	if is_attacking: return
	# attack_down_1
	animation_player.play("attack_down_1")
	# Configurar temporizador
	attack_cooldown = 0.6
	# Marcar o ataque
	is_attacking = true 
# -------------------------------------------------------------------------------------------------------
func deal_damage_to_enemies() -> void:
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Pawn Enemies"):
			var enemy: Enemy = body
			
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2 
			if sprite2d.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			
			var dot_product = direction_to_enemy.dot(attack_direction)
			
			if dot_product >= 0.5:
				enemy.damage(sword_damage)
			if dot_product <= -0.4:
				enemy.damage(sword_down)
# -------------------------------------------------------------------------------------------------------
func damage(amount: int) -> void:
	if health <= 0: return
	
	health -= amount
	print("Player recebeu dano de ", amount, ". A vida total é de ", health, "/", max_health )
	
	# Piscar o inimigo
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self,"modulate", Color.WHITE, 0.3)
	# Processar morte
	if health <= 0:
		die() 
# -------------------------------------------------------------------------------------------------------
func die() -> void:
	GameManager.end_game()
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position 
		get_parent().add_child(death_object)
		
	print("Player morreu")
	queue_free()
# -------------------------------------------------------------------------------------------------------
func udpate_hitbox_detection(delta: float):
	# Temporizador
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0: return
	# Frequência (1x por segundo ou 2x por segundo)
	hitbox_cooldown = 0.5
	# Detectar o Hitbox Area2D
	var bodies = hitbox.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Pawn Enemies"):
			var enemy: Enemy = body
			var damage_amount = 4
			damage(damage_amount)
# -------------------------------------------------------------------------------------------------------
func deal(amount: int) -> int:
	health += amount
	if health > max_health:
		health = max_health
	print("Player recebeu cura de ", amount, ". A vida total é de ", health, "/", max_health )
	return health
# -------------------------------------------------------------------------------------------------------
func udpate_ritual(delta:float) -> void:
	# Atualizar o temporizador
	ritual_cooldown -= delta
	if ritual_cooldown > 0: return
	
	# Reserta o temporizador
	ritual_cooldown = ritual_interval
	
	# Criar o ritual
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)
