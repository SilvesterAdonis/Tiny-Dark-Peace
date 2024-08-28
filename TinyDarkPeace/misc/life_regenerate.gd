extends AnimatedSprite2D
# -------------------------------------------------------------------------------------------------------
@export var regenerate_amount: int = 10
# -------------------------------------------------------------------------------------------------------
@onready var area2d: Area2D = $Area2D
# -------------------------------------------------------------------------------------------------------
func _ready() -> void:
	area2d.body_entered.connect(on_body_entered)
# -------------------------------------------------------------------------------------------------------
func on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Hero"):
		var player: Player = body
		player.deal(regenerate_amount)
		player.meat_collected.emit(regenerate_amount)
		queue_free()
# -------------------------------------------------------------------------------------------------------
