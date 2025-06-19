class CreateAppointments < ActiveRecord::Migration[8.0]
  def change
    create_table :appointments do |t|
      t.references :student, null: false, foreign_key: true
      t.references :time_slot, null: false, foreign_key: true
      t.text :notes

      t.timestamps
    end

    # インデックスを追加してクエリパフォーマンスを向上
    add_index :appointments, [:student_id, :time_slot_id], unique: true, name: 'index_appointments_unique'
    add_index :appointments, :time_slot_id, unique: true, name: 'index_appointments_time_slot_unique'
  end
end
