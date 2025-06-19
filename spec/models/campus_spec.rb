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

  describe '関連付けのテスト（多対多リレーション）' do
    describe 'students' do
      let(:campus) { create(:campus) }

      it '複数の生徒を持つことができること' do
        student1 = create(:student, name: "生徒1")
        student2 = create(:student, name: "生徒2")
        
        student1.campuses << campus
        student2.campuses << campus
        
        expect(campus.students).to include(student1, student2)
        expect(campus.students.count).to eq(2)
      end

      it '校舎が削除されても生徒は残ること（中間テーブルのみ削除）' do
        students = create_list(:student, 2)
        students.each { |student| student.campuses << campus }
        
        expect(campus.students.count).to eq(2)
        
        campus.destroy
        
        # 生徒は残っている
        students.each do |student|
          student.reload
          expect(student).to be_persisted
          expect(student.campuses).to be_empty  # 中間テーブルの関連のみ削除
        end
      end
      
      it '中間テーブル経由で関連付けられること' do
        student = create(:student)
        student.campuses << campus
        
        expect(campus.student_campus_affiliations.count).to eq(1)
        expect(campus.student_campus_affiliations.first.student).to eq(student)
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

  describe '複雑なシナリオのテスト（多対多対応）' do
    describe '校舎と生徒の多対多関係' do
      it '1つの校舎に複数の生徒が所属できること' do
        campus = create(:campus)
        students = create_list(:student, 3)
        
        students.each { |student| student.campuses << campus }
        expect(campus.students.count).to eq(3)
      end
      
      it '1人の生徒が複数の校舎に所属できること' do
        campuses = create_list(:campus, 2)
        student = create(:student)
        
        campuses.each { |campus| student.campuses << campus }
        expect(student.campuses.count).to eq(2)
      end
      
      it '校舎削除時に中間テーブルの関連が削除されること' do
        campus = create(:campus)
        students = create_list(:student, 2)
        students.each { |student| student.campuses << campus }
        
        expect(StudentCampusAffiliation.count).to eq(2)
        
        campus.destroy
        
        expect(StudentCampusAffiliation.count).to eq(0)
        students.each do |student|
          student.reload
          expect(student.campuses).to be_empty
        end
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

    describe '校舎別生徒数の集計（多対多対応）' do
      it '校舎ごとの生徒数を正しく集計できること' do
        campus1 = create(:campus, name: '校舎1')
        campus2 = create(:campus, name: '校舎2')
        
        # 校舎1に3人、校舎2に2人の生徒を所属させる
        students1 = create_list(:student, 3)
        students2 = create_list(:student, 2)
        
        students1.each { |student| student.campuses << campus1 }
        students2.each { |student| student.campuses << campus2 }
        
        # 1人の生徒を両方の校舎に所属させる
        shared_student = create(:student)
        shared_student.campuses << [campus1, campus2]
        
        expect(campus1.students.count).to eq(4)  # 3 + 1(shared)
        expect(campus2.students.count).to eq(3)  # 2 + 1(shared)
        
        # 全校舎の生徒数合計（重複なし）
        total_students = Student.joins(:campuses).distinct.count
        expect(total_students).to eq(6)  # 3 + 2 + 1(shared)
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

  # ===================================================================
  # 多対多リレーション用の新しいメソッドのテスト
  # ===================================================================
  
  describe '多対多リレーション用メソッドのテスト' do
    let(:campus) { create(:campus, name: "テスト校舎") }
    let(:student1) { create(:student, name: "生徒A") }
    let(:student2) { create(:student, name: "生徒B") }
    let(:student3) { create(:student, name: "生徒C") }

    describe 'student_count' do
      it '所属生徒がいない場合は0を返すこと' do
        expect(campus.student_count).to eq(0)
      end

      it '所属生徒数を正しく返すこと' do
        [student1, student2, student3].each { |student| student.campuses << campus }
        expect(campus.student_count).to eq(3)
      end
    end

    describe 'student_names' do
      it '所属生徒がいない場合は空配列を返すこと' do
        expect(campus.student_names).to eq([])
      end

      it '所属生徒の名前一覧を返すこと' do
        [student1, student2].each { |student| student.campuses << campus }
        expect(campus.student_names).to include("生徒A", "生徒B")
        expect(campus.student_names.count).to eq(2)
      end
    end

    describe 'has_student?' do
      before do
        student1.campuses << campus
      end

      it '所属している生徒に対してtrueを返すこと' do
        expect(campus.has_student?(student1)).to be true
      end

      it '所属していない生徒に対してfalseを返すこと' do
        expect(campus.has_student?(student2)).to be false
      end
    end

    describe 'add_student' do
      it '新しい生徒を追加できること' do
        campus.add_student(student1)
        expect(campus.students).to include(student1)
        expect(campus.students.count).to eq(1)
      end

      it '既に所属している生徒は重複追加されないこと' do
        student1.campuses << campus
        campus.add_student(student1)
        expect(campus.students.count).to eq(1)
      end
    end

    describe 'remove_student' do
      before do
        [student1, student2].each { |student| student.campuses << campus }
      end

      it '指定した生徒を削除できること' do
        campus.remove_student(student1)
        expect(campus.students).not_to include(student1)
        expect(campus.students).to include(student2)
      end

      it '所属していない生徒を削除してもエラーにならないこと' do
        expect { campus.remove_student(student3) }.not_to raise_error
      end
    end

    describe 'time_slot_count' do
      it '面談枠がない場合は0を返すこと' do
        expect(campus.time_slot_count).to eq(0)
      end

      it '面談枠数を正しく返すこと' do
        teacher = create(:teacher)
        # 時間をずらして重複を回避
        create(:time_slot, campus: campus, teacher: teacher, start_time: Time.parse("15:00"))
        create(:time_slot, campus: campus, teacher: teacher, start_time: Time.parse("15:10"))
        expect(campus.time_slot_count).to eq(2)
      end
    end

    describe 'info' do
      it '校舎の基本情報を文字列で返すこと' do
        [student1, student2].each { |student| student.campuses << campus }
        teacher = create(:teacher)
        create(:time_slot, campus: campus, teacher: teacher, start_time: Time.parse("16:00"))
        
        expect(campus.info).to eq("テスト校舎 (生徒数: 2名, 面談枠: 1件)")
      end
    end
  end
end
