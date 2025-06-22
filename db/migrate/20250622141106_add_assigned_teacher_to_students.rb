class AddAssignedTeacherToStudents < ActiveRecord::Migration[8.0]
  def change
    add_reference :students, :assigned_teacher, null: true, foreign_key: { to_table: :teachers, on_delete: :nullify }
  end
end
