class Appointment < ActiveRecord::Base
	#belongs_to :user, inverse_of: :attendance, :class_name => "User"
	#belongs_to :created_by, inverse_of: :creators, :class_name => "User"
	belongs_to :user
	belongs_to :client
	belongs_to :case_type
	after_save :clear_cache

end
