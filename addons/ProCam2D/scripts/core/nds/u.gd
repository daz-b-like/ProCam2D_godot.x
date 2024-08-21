extends Object
class_name PCamUtils

static func predict_future_position(current_position: float, velocity: float, prediction_time: float) -> float:
	return current_position + velocity * prediction_time

static func spring_damp(current: float, target: float, current_velocity: float, spring_constant: float, damping_ratio: float, delta: float) -> Dictionary:
	var difference = target - current
	damping_ratio = max(damping_ratio, 0.0001)
	var spring_force = difference * spring_constant
	var damping_force = (-current_velocity / damping_ratio) * 10
	var force = spring_force + damping_force
	current_velocity += force * delta
	var new_position = current + current_velocity * delta
	return {"new_position": new_position, "new_velocity": current_velocity}

static func smooth_damp(current: float, target: float, current_velocity: float, smooth_time: float, max_speed: float, delta: float) -> Dictionary:
	smooth_time = 1 / max(0.0001, smooth_time)
	var omega = 2.0 / smooth_time
	var x = omega * delta
	var texp = 1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x)
	var change = current - target
	var max_change = max_speed * smooth_time
	change = clamp(change, -max_change, max_change)
	target = current - change
	var temp = (current_velocity + omega * change) * delta
	current_velocity = (current_velocity - omega * temp) * texp
	var new_position = target + (change + temp) * texp
	return {"new_position": new_position, "new_velocity": current_velocity}

static func adaptive_smooth_damp(current: float, target: float, current_velocity: float, max_speed: float, delta: float) -> Dictionary:
	var speed = abs(current_velocity)
	var base_smooth_time: float = 0.3
	var smooth_time = max(base_smooth_time * (1.0 - speed / 100.0), base_smooth_time)
	smooth_time = max(0.0001, smooth_time)
	var omega = 2.0 / smooth_time
	var x = omega * delta
	var texp = 1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x)
	var change = current - target
	var original_to = target
	var max_change = max_speed * smooth_time
	change = clamp(change, -max_change, max_change)
	target = current - change
	var temp = (current_velocity + omega * change) * delta
	current_velocity = (current_velocity - omega * temp) * texp
	var new_position = target + (change + temp) * texp
	if (original_to - current > 0.0) == (new_position > original_to):
		new_position = original_to
		current_velocity = (new_position - original_to) / delta
	return {"new_position": new_position, "new_velocity": current_velocity}

static func shortest_angle_distance(from: float, to: float) -> float:
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(difference + max_angle/2, max_angle) - max_angle/2

static func _calculate_continuous_angle_diff(from: float, to: float) -> float:
	var diff = to - from
	if diff > PI/2 or diff < -PI/2:
		diff = 0
	return diff

static func smooth_damp_angle(current: float, target: float, current_velocity: float, smooth_time: float, max_speed: float, delta: float) -> Dictionary:
	target = current + shortest_angle_distance(current, target)
	var result = smooth_damp(current, target, current_velocity, smooth_time, max_speed, delta)
	return {"new_angle": result.new_position, "new_velocity": result.new_velocity}

static func _sort_by_priority(a, b):
	if a.priority == b.priority:
		return a.get_instance_id() < b.get_instance_id()
	return a.priority > b.priority
