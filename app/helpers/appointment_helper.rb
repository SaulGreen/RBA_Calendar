module AppointmentHelper
	# def fetch_appointments
	# 	appointments = $redis.get("appointments")

	# 	if appointments.nil?
	# 		appointments = Appointment.all.to_json
	# 		$redis.set("appointments",appointments)
	# 		#Expire cache every hour
	# 		$redis.expire("appointments",3.hour.to_i)
	# 	end

	# 	@appointments = JSON.load appointments
	# end
end
