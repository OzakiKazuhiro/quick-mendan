require 'rails_helper'

RSpec.describe StudentsController, type: :routing do
  describe 'routing' do
    it 'GET /student/dashboard が students#dashboard にルーティングされること' do
      expect(get: '/student/dashboard').to route_to('students#dashboard')
    end

    it 'student_dashboard_path ヘルパーが正しいパスを生成すること' do
      expect(student_dashboard_path).to eq('/student/dashboard')
    end
  end
end 