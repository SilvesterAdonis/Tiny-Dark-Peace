extends Node2D

@export var value: int = 0

@onready var label: Label = $Node2D/Label

func _ready():
	label.text = str(value)
	pass
