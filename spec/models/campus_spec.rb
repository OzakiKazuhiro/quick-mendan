require 'rails_helper'

RSpec.describe Campus, type: :model do
  describe 'ファクトリのテスト' do
    it 'valid factoryが有効であること' do
      campus = build(:campus)
      expect(campus).to be_valid
    end

    it '実際の校舎名のtraitが有効であること' do
      campus = build(:campus, :mikunigaoka)
      expect(campus).to be_valid
      expect(campus.name).to eq('三国ヶ丘本部校')
    end

    it 'with_students traitが有効であること' do
      campus = create(:campus, :with_students)
      expect(campus).to be_valid
      expect(campus.students.count).to eq(3)
    end
  end

  describe '関連付けのテスト' do
    describe 'students' do
      let(:campus) { create(:campus) }

      it '生徒を複数持つことができること' do
        student1 = create(:student, campus: campus)
        student2 = create(:student, campus: campus)
        
        expect(campus.students).to include(student1, student2)
        expect(campus.students.count).to eq(2)
      end

      it '校舎が削除されても生徒は残ること' do
        student = create(:student, campus: campus)
        campus_id = campus.id
        
        campus.destroy
        
        student.reload
        expect(student).to be_persisted
        expect(student.campus_id).to be_nil
      end
    end
  end

  describe 'バリデーションのテスト' do
    let(:campus) { build(:campus) }

    describe 'name' do
      it '存在する場合は有効であること' do
        campus.name = '新しい校舎'
        expect(campus).to be_valid
      end

      it '存在しない場合は無効であること' do
        campus.name = nil
        expect(campus).not_to be_valid
        expect(campus.errors[:name]).to include("can't be blank")
      end

      it '空文字の場合は無効であること' do
        campus.name = ''
        expect(campus).not_to be_valid
        expect(campus.errors[:name]).to include("can't be blank")
      end

      it '重複する場合は無効であること' do
        create(:campus, name: '重複テスト校舎')
        campus.name = '重複テスト校舎'
        expect(campus).not_to be_valid
        expect(campus.errors[:name]).to include("has already been taken")
      end

      it '同じ名前でも大文字小文字が違えば有効であること' do
        create(:campus, name: 'test campus')
        campus.name = 'Test Campus'
        expect(campus).to be_valid
      end
    end
  end

  describe 'スコープのテスト' do
    describe 'ordered' do
      it '名前順でソートされること' do
        campus_c = create(:campus, name: 'C校舎')
        campus_a = create(:campus, name: 'A校舎')
        campus_b = create(:campus, name: 'B校舎')
        
        ordered_campuses = Campus.ordered
        expect(ordered_campuses.first).to eq(campus_a)
        expect(ordered_campuses.second).to eq(campus_b)
        expect(ordered_campuses.third).to eq(campus_c)
      end

      it '空の場合でもエラーにならないこと' do
        expect { Campus.ordered }.not_to raise_error
        expect(Campus.ordered.count).to eq(0)
      end
    end
  end

  describe '実際の校舎データのテスト' do
    describe '三国ヶ丘本部校' do
      it '正しい名前で作成されること' do
        campus = create(:campus, :mikunigaoka)
        expect(campus.name).to eq('三国ヶ丘本部校')
      end
    end

    describe '泉ヶ丘駅前校' do
      it '正しい名前で作成されること' do
        campus = create(:campus, :izumigaoka)
        expect(campus.name).to eq('泉ヶ丘駅前校')
      end
    end

    describe '岸和田校' do
      it '正しい名前で作成されること' do
        campus = create(:campus, :kishiwada)
        expect(campus.name).to eq('岸和田校')
      end
    end

    describe '鳳駅前校' do
      it '正しい名前で作成されること' do
        campus = create(:campus, :otori)
        expect(campus.name).to eq('鳳駅前校')
      end
    end
  end

  describe 'データベース保存のテスト' do
    it 'nameフィールドが保存されること' do
      campus = create(:campus, name: '保存テスト校舎')
      
      saved_campus = Campus.find(campus.id)
      expect(saved_campus.name).to eq('保存テスト校舎')
    end
  end

  describe '複雑なシナリオのテスト' do
    describe '校舎と生徒の関係' do
      it '校舎削除時に生徒の校舎情報がnullifyされること' do
        campus = create(:campus)
        student1 = create(:student, campus: campus)
        student2 = create(:student, campus: campus)
        
        expect(campus.students.count).to eq(2)
        
        campus.destroy
        
        student1.reload
        student2.reload
        expect(student1.campus).to be_nil
        expect(student2.campus).to be_nil
      end
    end

    describe '校舎名での検索' do
      before do
        create(:campus, :mikunigaoka)
        create(:campus, :izumigaoka)
        create(:campus, :kishiwada)
        create(:campus, :otori)
      end

      it '部分一致で検索できること' do
        results = Campus.where("name LIKE ?", "%駅前%")
        expect(results.count).to eq(2)
        expect(results.pluck(:name)).to include('泉ヶ丘駅前校', '鳳駅前校')
      end

      it '完全一致で検索できること' do
        result = Campus.find_by(name: '三国ヶ丘本部校')
        expect(result).to be_present
        expect(result.name).to eq('三国ヶ丘本部校')
      end
    end

    describe '校舎別生徒数の集計' do
      it '校舎ごとの生徒数を正しく集計できること' do
        campus1 = create(:campus, name: '校舎1')
        campus2 = create(:campus, name: '校舎2')
        
        create_list(:student, 3, campus: campus1)
        create_list(:student, 2, campus: campus2)
        create(:student, campus: nil)  # 校舎未設定の生徒
        
        expect(campus1.students.count).to eq(3)
        expect(campus2.students.count).to eq(2)
        
        # 全校舎の生徒数合計
        total_with_campus = Campus.joins(:students).count
        expect(total_with_campus).to eq(5)
      end
    end
  end

  describe 'エラーハンドリングのテスト' do
    it '無効なデータでの保存時に適切なエラーメッセージが返されること' do
      campus = build(:campus, name: nil)
      expect(campus).not_to be_valid
      expect(campus.errors.full_messages).to include("Name can't be blank")
    end

    it '重複データでの保存時に適切なエラーメッセージが返されること' do
      create(:campus, name: '重複校舎名')
      duplicate_campus = build(:campus, name: '重複校舎名')
      
      expect(duplicate_campus).not_to be_valid
      expect(duplicate_campus.errors.full_messages).to include("Name has already been taken")
    end
  end
end
