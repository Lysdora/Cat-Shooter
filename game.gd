extends Node

signal score_changed(score:int)

var score: int = 0

func add_score(amount: int):
	score += amount
	score_changed.emit(score)
