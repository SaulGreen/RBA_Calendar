class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.string :titulo
      t.text :comentario
      t.date :fecha
      t.time :horainicio
      t.time :horafinal
      t.integer :id_user
      t.boolean :completo

      t.timestamps null: false
    end
  end
end
