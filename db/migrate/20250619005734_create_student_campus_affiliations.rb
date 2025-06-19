class CreateStudentCampusAffiliations < ActiveRecord::Migration[8.0]
  def change
    create_table :student_campus_affiliations do |t|
      t.references :student, null: false, foreign_key: true  # 生徒への参照（自動的にstudent_idインデックス作成）
      t.references :campus, null: false, foreign_key: true   # 校舎への参照（自動的にcampus_idインデックス作成）

      t.timestamps
    end

    # 複合ユニークインデックス追加：同じ生徒が同じ校舎に重複所属することを防ぐ
    add_index :student_campus_affiliations, [:student_id, :campus_id], 
              unique: true, name: 'index_student_campus_unique'
  end
end
