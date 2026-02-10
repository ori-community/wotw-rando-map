extends Object
class_name StringUtils


static func format_time(value: float) -> String:
	var total_seconds := int(value)
	
	var hours := int(total_seconds / 3600.0)
	var minutes := (total_seconds % 3600) / 60.0
	var seconds := total_seconds % 60
	
	var milliseconds := int((value - total_seconds) * 10)
	
	return "%02d:%02d:%02d.%d" % [hours, minutes, seconds, milliseconds]
