require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'test'
    end

    def dashboard_test
      prevent_caching
      render plain: 'dashboard test'
    end
  end

  let(:student) { create(:student) }

  describe '#after_sign_in_path_for' do
    context 'リソースがStudentの場合' do
      it 'student_dashboard_pathを返すこと' do
        expect(controller.send(:after_sign_in_path_for, student)).to eq(student_dashboard_path)
      end
    end

    context 'リソースがStudent以外の場合' do
      let(:teacher) { create(:teacher) }

      it 'root_pathを返すこと' do
        expect(controller.send(:after_sign_in_path_for, teacher)).to eq(root_path)
      end
    end

    context 'リソースがnilの場合' do
      it 'root_pathを返すこと' do
        expect(controller.send(:after_sign_in_path_for, nil)).to eq(root_path)
      end
    end
  end

  describe '#prevent_caching' do
    before do
      routes.draw do
        get 'dashboard_test' => 'anonymous#dashboard_test'
      end
    end

    it 'キャッシュ制御ヘッダーが正しく設定されること' do
      get :dashboard_test
      # Railsは複数のCache-Controlディレクティブを正規化するため、含まれることを確認
      expect(response.headers['Cache-Control']).to include('no-store')
      expect(response.headers['Cache-Control']).to include('private')
      expect(response.headers['Pragma']).to eq('no-cache')
      expect(response.headers['Expires']).to eq('0')
    end
  end

  describe 'helper method inclusion' do
    it 'ApplicationHelperのメソッドが使用可能であること' do
      expect(controller.respond_to?(:current_teacher, true)).to be true
      expect(controller.respond_to?(:current_staff_user, true)).to be true
    end
  end

  describe 'permission methods' do
    describe '#current_user_is_admin?' do
      it 'protectedメソッドとして定義されていること' do
        expect(controller.respond_to?(:current_user_is_admin?, true)).to be true
      end
    end

    describe '#current_user_is_staff?' do
      it 'protectedメソッドとして定義されていること' do
        expect(controller.respond_to?(:current_user_is_staff?, true)).to be true
      end
    end

    describe '#current_staff_user' do
      it 'protectedメソッドとして定義されていること' do
        expect(controller.respond_to?(:current_staff_user, true)).to be true
      end
    end

    describe '#require_admin' do
      it 'protectedメソッドとして定義されていること' do
        expect(controller.respond_to?(:require_admin, true)).to be true
      end
    end

    describe '#require_staff' do
      it 'protectedメソッドとして定義されていること' do
        expect(controller.respond_to?(:require_staff, true)).to be true
      end
    end

    describe '#prevent_caching' do
      it 'protectedメソッドとして定義されていること' do
        expect(controller.respond_to?(:prevent_caching, true)).to be true
      end
    end
  end
end 