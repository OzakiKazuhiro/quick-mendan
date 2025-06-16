class CreateTimeSlots < ActiveRecord::Migration[8.0]
  def change
    create_table :time_slots do |t|
      t.references :teacher, null: false, foreign_key: true
      t.references :campus, null: false, foreign_key: true
      t.date :date, null: false
      t.time :start_time, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    # インデックスを追加してクエリパフォーマンスを向上
    add_index :time_slots, [:teacher_id, :date, :start_time], unique: true, name: 'index_time_slots_unique'
    add_index :time_slots, [:campus_id, :date, :start_time]
    add_index :time_slots, [:date, :start_time]
    add_index :time_slots, :status
  end
end
