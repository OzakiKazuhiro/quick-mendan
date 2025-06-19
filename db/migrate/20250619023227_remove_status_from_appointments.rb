class RemoveStatusFromAppointments < ActiveRecord::Migration[8.0]
  def change
    # statusに関連するインデックスを削除
    remove_index :appointments, name: 'index_appointments_on_student_id_and_status'
    remove_index :appointments, name: 'index_appointments_on_status'
    
    # statusカラムを削除
    remove_column :appointments, :status, :integer
  end
end
