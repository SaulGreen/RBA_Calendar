class AddFieldsToAnnouncements < ActiveRecord::Migration
	  def change
	  		add_column :announcements, :created_by, :integer
  			add_column :announcements, :last_edited_by, :integer
  			add_column :announcements, :type_announce, :integer
  			add_column :announcements, :status_announce, :integer, :default => 1
  			add_column :announcements, :authorized_by, :integer
  			add_foreign_key :announcements, :users, column: :created_by, primary_key: :id
  			add_foreign_key :announcements, :users, column: :last_edited_by, primary_key: :id
  			add_foreign_key :announcements, :users, column: :authorized_by, primary_key: :id
	  end
end
