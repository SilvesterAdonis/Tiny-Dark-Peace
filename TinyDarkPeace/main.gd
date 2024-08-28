extends Node2D
# -------------------------------------------------------------------------------------------------------
@export var game_ui: CanvasLayer
# -------------------------------------------------------------------------------------------------------
func _ready():
	GameManager.game_over.connect(trigger_game_over)
# -------------------------------------------------------------------------------------------------------
func trigger_game_over():
	# Deletar a UI
	if game_ui:
		game_ui.queue_free()
		game_ui = null
	# Criar GameOverUi
	var game_over_ui_template: PackedScene = preload("res://ui/game_over_ui.tscn")
	var game_over_ui: GameOverUi = game_over_ui_template.instantiate()
	add_child(game_over_ui)
