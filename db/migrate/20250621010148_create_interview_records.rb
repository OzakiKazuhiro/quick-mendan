class CreateInterviewRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :interview_records do |t|
      t.references :appointment, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
