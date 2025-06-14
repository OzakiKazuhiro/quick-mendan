class CreateCampus < ActiveRecord::Migration[8.0]
  def change
    create_table :campus do |t|
      t.string :name, null: false

      t.timestamps
    end
    
    # インデックス追加：校舎名での検索を高速化 + 重複防止
    # unique: true により同じ校舎名の重複登録を防ぐ
    add_index :campus, :name, unique: true
  end
end
