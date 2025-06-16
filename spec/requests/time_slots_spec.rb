require 'rails_helper'

RSpec.describe "TimeSlots", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/time_slots/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/time_slots/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/time_slots/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/time_slots/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/time_slots/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
