require 'rails_helper'

RSpec.describe StudentCampusAffiliation, type: :model do
  # ===================================================================
  # 中間テーブルモデルのテスト
  # 生徒と校舎の多対多リレーションを管理するモデルのテスト
  # ===================================================================
  
  describe 'ファクトリのテスト' do
    it 'valid factoryが有効であること' do
      affiliation = build(:student_campus_affiliation)
      expect(affiliation).to be_valid
    end

    it 'with_specific_data traitが有効であること' do
      student = create(:student)
      campus = create(:campus)
      affiliation = build(:student_campus_affiliation, :with_specific_data, 
                          specific_student: student, specific_campus: campus)
      expect(affiliation).to be_valid
      expect(affiliation.student).to eq(student)
      expect(affiliation.campus).to eq(campus)
    end

    it '実際の校舎名のtraitが有効であること' do
      affiliation = build(:student_campus_affiliation, :mikunigaoka_affiliation)
      expect(affiliation).to be_valid
      expect(affiliation.campus.name).to eq('三国ヶ丘本部校')
    end
  end

  describe '関連付けのテスト' do
    let(:affiliation) { create(:student_campus_affiliation) }

    describe 'student' do
      it '生徒との関連付けが必須であること' do
        affiliation.student = nil
        expect(affiliation).not_to be_valid
        expect(affiliation.errors[:student]).to include("must exist")
      end

      it '生徒との関連付けが正しく動作すること' do
        student = create(:student)
        affiliation.student = student
        expect(affiliation.student).to eq(student)
      end
    end

    describe 'campus' do
      it '校舎との関連付けが必須であること' do
        affiliation.campus = nil
        expect(affiliation).not_to be_valid
        expect(affiliation.errors[:campus]).to include("must exist")
      end

      it '校舎との関連付けが正しく動作すること' do
        campus = create(:campus)
        affiliation.campus = campus
        expect(affiliation.campus).to eq(campus)
      end
    end
  end

  describe 'バリデーションのテスト' do
    let(:student) { create(:student) }
    let(:campus) { create(:campus) }

    describe 'ユニーク制約' do
      it '同じ生徒と校舎の組み合わせは1つのみ許可されること' do
        create(:student_campus_affiliation, student: student, campus: campus)
        duplicate_affiliation = build(:student_campus_affiliation, 
                                      student: student, campus: campus)
        
        expect(duplicate_affiliation).not_to be_valid
        expect(duplicate_affiliation.errors[:student_id])
          .to include("この生徒は既にこの校舎に所属しています")
      end

      it '同じ生徒でも異なる校舎なら有効であること' do
        campus2 = create(:campus, name: "別の校舎")
        create(:student_campus_affiliation, student: student, campus: campus)
        
        second_affiliation = build(:student_campus_affiliation, 
                                   student: student, campus: campus2)
        expect(second_affiliation).to be_valid
      end

      it '同じ校舎でも異なる生徒なら有効であること' do
        student2 = create(:student, student_number: "9999")
        create(:student_campus_affiliation, student: student, campus: campus)
        
        second_affiliation = build(:student_campus_affiliation, 
                                   student: student2, campus: campus)
        expect(second_affiliation).to be_valid
      end
    end
  end

  describe 'スコープのテスト' do
    let!(:student1) { create(:student, name: "生徒1") }
    let!(:student2) { create(:student, name: "生徒2") }
    let!(:campus1) { create(:campus, name: "校舎1") }
    let!(:campus2) { create(:campus, name: "校舎2") }
    let!(:affiliation1) { create(:student_campus_affiliation, student: student1, campus: campus1) }
    let!(:affiliation2) { create(:student_campus_affiliation, student: student2, campus: campus1) }
    let!(:affiliation3) { create(:student_campus_affiliation, student: student1, campus: campus2) }

    describe 'by_campus' do
      it '指定した校舎の所属関係のみ取得できること' do
        results = StudentCampusAffiliation.by_campus(campus1)
        expect(results).to include(affiliation1, affiliation2)
        expect(results).not_to include(affiliation3)
        expect(results.count).to eq(2)
      end
    end

    describe 'by_student' do
      it '指定した生徒の所属関係のみ取得できること' do
        results = StudentCampusAffiliation.by_student(student1)
        expect(results).to include(affiliation1, affiliation3)
        expect(results).not_to include(affiliation2)
        expect(results.count).to eq(2)
      end
    end

    describe 'recent' do
      it '作成日時の降順で取得できること' do
        sleep(0.01) # 時間差を作るため
        latest_affiliation = create(:student_campus_affiliation)
        
        results = StudentCampusAffiliation.recent
        expect(results.first).to eq(latest_affiliation)
      end
    end
  end

  describe 'インスタンスメソッドのテスト' do
    describe 'affiliation_info' do
      it '生徒名と校舎名を組み合わせた文字列を返すこと' do
        student = create(:student, name: "田中太郎")
        campus = create(:campus, name: "テスト校舎")
        affiliation = create(:student_campus_affiliation, student: student, campus: campus)
        
        expect(affiliation.affiliation_info).to eq("田中太郎 - テスト校舎")
      end
    end
  end

  describe 'データベース制約のテスト' do
    it 'データベースレベルでのユニーク制約が機能すること' do
      student = create(:student)
      campus = create(:campus)
      
      # 最初のレコードは成功
      create(:student_campus_affiliation, student: student, campus: campus)
      
      # 同じ組み合わせで重複挿入を試みる（SQL直接実行）
      expect {
        StudentCampusAffiliation.connection.execute(
          "INSERT INTO student_campus_affiliations (student_id, campus_id, created_at, updated_at) 
           VALUES (#{student.id}, #{campus.id}, '#{Time.current}', '#{Time.current}')"
        )
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe '実際の使用シナリオのテスト' do
    describe '生徒の転校舎シナリオ' do
      it '生徒が一つの校舎から別の校舎に移る場合のテスト' do
        student = create(:student, name: "転校生")
        old_campus = create(:campus, name: "旧校舎")
        new_campus = create(:campus, name: "新校舎")
        
        # 最初の校舎に所属
        old_affiliation = create(:student_campus_affiliation, 
                                 student: student, campus: old_campus)
        expect(student.campuses).to include(old_campus)
        
        # 新しい校舎に所属
        new_affiliation = create(:student_campus_affiliation, 
                                 student: student, campus: new_campus)
        student.reload
        expect(student.campuses).to include(old_campus, new_campus)
        
        # 旧校舎から除外
        old_affiliation.destroy
        student.reload
        expect(student.campuses).to include(new_campus)
        expect(student.campuses).not_to include(old_campus)
      end
    end

    describe '校舎の統廃合シナリオ' do
      it '校舎が削除された場合の所属関係処理' do
        students = create_list(:student, 3)
        campus = create(:campus, name: "統合される校舎")
        
        # 複数生徒を校舎に所属させる
        students.each do |student|
          create(:student_campus_affiliation, student: student, campus: campus)
        end
        
        expect(campus.students.count).to eq(3)
        
        # 校舎を削除（dependent: :destroyにより関連レコードも削除）
        campus.destroy
        
        # 所属関係レコードも削除されていることを確認
        students.each do |student|
          student.reload
          expect(student.campuses).to be_empty
        end
      end
    end
  end
end
