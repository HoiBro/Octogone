extends Node2D

@export var reload_time: float = 1.8
@export var recoil: int = 1500
@export var ready_to_fire: bool = true
@export var raycast_length: int = 2000

@onready var player: CharacterBody2D = $".."
@onready var shotgun_sprite: Sprite2D = $"../PlayerSprite/ShotgunSprite"
@onready var graphook_sprite: Sprite2D = $"../PlayerSprite/Grapplinghook"
@onready var grap_sprite: Sprite2D = $"../PlayerSprite/Grappling"
@onready var hook_sprite: Sprite2D = $"../PlayerSprite/Hook"

var MPOS: Vector2 = Vector2.ZERO
var ANGLE: float = 0
var V_RELATIVE: Vector2 = Vector2.ZERO
var BOUNCE: float = 0.1
var QUERY: PhysicsRayQueryParameters2D
var CAST: Dictionary = {}

func _input(event) -> void:
	if event.is_action_pressed(&"fire_shotgun") and ready_to_fire:
		#Funky shotgun shit
		MPOS = get_local_mouse_position().normalized()
		ANGLE = MPOS.angle_to(Vector2.UP)
		V_RELATIVE = player.velocity.rotated(ANGLE)
		if V_RELATIVE.y < 0:
			player.velocity = Vector2(V_RELATIVE.x, -BOUNCE * V_RELATIVE.y).rotated(-ANGLE) - MPOS * recoil
		else:
			player.velocity += -MPOS * recoil
		
		player.just_jumped = false
		
		get_tree().create_timer(reload_time, false).timeout.connect(_on_reload_timer_timeout)
		get_tree().create_timer(0.1, false).timeout.connect(spread_reset)
		
		$Shotgun.play()
		
		shotgun_sprite.show()
		graphook_sprite.hide()
		grap_sprite.hide()
		
		for i in range(11):
			QUERY = PhysicsRayQueryParameters2D.create(player.position, player.position + (MPOS * raycast_length).rotated(-0.075 * PI + i * 0.015 * PI), 1, [player])
			CAST = get_world_2d().direct_space_state.intersect_ray(QUERY)
			$SpreadLine.add_point(player.position)
			
			if CAST != {} and CAST.collider != null:
				$SpreadLine.add_point(CAST.position)
				if CAST.collider is RigidBody2D:
					if get_node(CAST.collider.get_path()).has_method("damage"): #Check whether the node can be damaged
						get_node(CAST.collider.get_path()).damage(10)
			elif CAST == {}:
				$SpreadLine.add_point(player.position + (MPOS * raycast_length).rotated(-0.075 * PI + i * 0.015 * PI))
		
		ready_to_fire = false

func _on_reload_timer_timeout() -> void:
	ready_to_fire = true
	if is_inside_tree():
		$Reload.play()

##Removes the shotgun spread
func spread_reset():
	$SpreadLine.clear_points()
