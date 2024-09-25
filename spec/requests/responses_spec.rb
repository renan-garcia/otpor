require "rails_helper"

RSpec.describe "Responses", type: :request do
  it "returns the default response in JSON using the gem" do
    get "/my_action", headers: { "Accept" => "application/json" }

    json_response = JSON.parse(response.body)

    expect(json_response["status"]["name"]).to eq("OK")
    expect(json_response["status"]["code"]).to eq(200)
    expect(json_response["status"]["type"]).to eq("Success")
    expect(json_response["data"]["my_variable"]).to eq("Hello from FakeController")
  end

  context "when an exception occurs" do
    before do
      allow_any_instance_of(FakesController).to receive(:my_action).and_raise(ActiveRecord::RecordNotFound,
                                                                              "Record not found")
    end

    it "captures ActiveRecord::RecordNotFound and returns 404" do
      get "/my_action", headers: { "Accept" => "application/json" }

      json_response = JSON.parse(response.body)

      expect(response.status).to eq(404)
      expect(json_response["status"]["name"]).to eq("Not Found")
      expect(json_response["status"]["type"]).to eq("Client Error")
      expect(json_response["errors"]).to be_nil
    end
  end

  context "when the response status is customized" do
    it "customizes the response status and returns errors" do
      allow_any_instance_of(FakesController).to receive(:default_render).and_call_original
      get "/my_action_custom_status", headers: { "Accept" => "application/json" }

      json_response = JSON.parse(response.body)

      expect(response.status).to eq(422)
      expect(json_response["status"]["name"]).to eq("Unprocessable Content")
      expect(json_response["status"]["type"]).to eq("Client Error")
      expect(json_response["errors"].first["message"]).to eq("Invalid data")
    end
  end

  context "when the response includes pagination metadata" do
    before do
      ActiveRecord::Schema.define do
        create_table :temp_items, force: true do |t|
          t.string :name
          t.timestamps
        end
      end

      class TempItem < ActiveRecord::Base
        self.table_name = "temp_items"
      end

      25.times { |i| TempItem.create!(name: "Item #{i + 1}") }
    end

    it "returns the API version" do
      get "/v1/fakes/my_action", headers: { "Accept" => "application/json" }
      json_response = JSON.parse(response.body)

      expect(json_response["meta"]["api_version"]).to eq("v1")
    end

    it "includes pagination metadata in the JSON response" do
      get "/my_action_pagination", headers: { "Accept" => "application/json" }

      json_response = JSON.parse(response.body)

      expect(json_response["meta"]).to include(
        "pagination" => {
          "total_pages" => 3,
          "total_count" => 25,
          "current_page" => 1,
          "next_page" => 2,
          "prev_page" => nil,
          "per_page" => 10
        }
      )
    end

    after do
      ActiveRecord::Schema.define do
        drop_table :temp_items, if_exists: true
      end
      Object.send(:remove_const, :TempItem) if defined?(TempItem)
    end
  end
end
