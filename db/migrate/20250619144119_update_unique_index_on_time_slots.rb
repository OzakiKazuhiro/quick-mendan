class UpdateUniqueIndexOnTimeSlots < ActiveRecord::Migration[8.0]
  def change
    # 既存の一意制約インデックスを削除
    remove_index :time_slots, [:teacher_id, :date, :start_time], 
                 if_exists: true, 
                 name: "index_time_slots_on_teacher_id_and_date_and_start_time"
    
    # 新しい一意制約インデックスを追加（campus_idを含む）
    add_index :time_slots, [:teacher_id, :date, :start_time, :campus_id], 
              unique: true, 
              name: "index_time_slots_on_teacher_date_time_campus"
  end
end
