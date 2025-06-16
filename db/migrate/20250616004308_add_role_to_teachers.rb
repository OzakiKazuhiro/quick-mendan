class AddRoleToTeachers < ActiveRecord::Migration[8.0]
  def change
    add_column :teachers, :role, :integer, default: 0, null: false
    add_index :teachers, :role
  end
end
