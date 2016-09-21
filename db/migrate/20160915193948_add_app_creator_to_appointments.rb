class AddAppCreatorToAppointments < ActiveRecord::Migration
  	def change
  		add_column :appointments, :created_by, :integer
  		add_column :appointments, :last_edited_by, :integer
  		add_foreign_key :appointments, :users, column: :created_by, primary_key: :id
  		add_foreign_key :appointments, :users, column: :last_edited_by, primary_key: :id
  	end
end
