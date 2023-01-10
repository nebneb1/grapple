extends Node

#var regen : Node
var ball : RigidBody2D
var scoreboard : RichTextLabel
var scores := [0, 0]
var players = []

var time := 300.0
var active := true

func _process(delta):
	if active: time -= delta

