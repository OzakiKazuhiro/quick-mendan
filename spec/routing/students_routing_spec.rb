require 'rails_helper'

RSpec.describe StudentsController, type: :routing do
  describe 'routing' do
    it 'GET /student/login が students#login にルーティングされること' do
      expect(get: '/student/login').to route_to('students#login')
    end

    it 'POST /student/login が students#authenticate にルーティングされること' do
      expect(post: '/student/login').to route_to('students#authenticate')
    end

    it 'DELETE /student/logout が students#logout にルーティングされること' do
      expect(delete: '/student/logout').to route_to('students#logout')
    end

    it 'GET /student/dashboard が students#dashboard にルーティングされること' do
      expect(get: '/student/dashboard').to route_to('students#dashboard')
    end

    it 'student_login_path ヘルパーが正しいパスを生成すること' do
      expect(student_login_path).to eq('/student/login')
    end

    it 'student_dashboard_path ヘルパーが正しいパスを生成すること' do
      expect(student_dashboard_path).to eq('/student/dashboard')
    end

    it 'student_logout_path ヘルパーが正しいパスを生成すること' do
      expect(student_logout_path).to eq('/student/logout')
    end
  end
end 