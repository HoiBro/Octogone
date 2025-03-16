extends RigidBody2D

@export var enemy_stats = {
	"health": 10
}
@export var accel = 500
@export var charge_time = 1

@onready var player = $"../..".get_child(-1)

var MOVING: bool = false
var TARGET_POS: Vector2 = Vector2.ZERO
var DIRECTION: Vector2 = Vector2.ZERO

func _ready() -> void:
	player.died.connect(player_death)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"respawn"):
		if $"../..".get_child(-1) is not CharacterBody2D:
			get_tree().create_timer(0.01).timeout.connect(respawn_check)

func damage(amount: int) -> void:
	enemy_stats.health -= amount
	if enemy_stats.health <= 0:
		remove_child($Hitbox)
		queue_free()

func player_detected(rid, body, _body_index, _local_index):
	if body == player and player.get_rid() == rid:
		if not MOVING:
			MOVING = true
			movement_start()

func movement_start() -> void:
	if MOVING:
		TARGET_POS = player.position
		DIRECTION = player.position - self.position
		linear_velocity = Vector2(accel, accel) * DIRECTION.normalized()
		get_tree().create_timer(charge_time, false).timeout.connect(movement_start)

func body_collision(rid, body, _body_index, _local_index) -> void:
	if body == player and player.get_rid() == rid:
		player.death()

func respawn_check():
	player = $"../..".get_child(-1)
	player.died.connect(player_death)

func player_death():
	MOVING = false
	linear_velocity = Vector2.ZERO
