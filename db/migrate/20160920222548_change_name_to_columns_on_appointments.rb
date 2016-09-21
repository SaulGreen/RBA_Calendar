class ChangeNameToColumnsOnAppointments < ActiveRecord::Migration
  def change
  		rename_column :appointments, :created_by, :created_by_id
  		rename_column :appointments, :last_edited_by, :last_edited_by_id
  end
end
