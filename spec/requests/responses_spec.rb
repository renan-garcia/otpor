require "rails_helper"

RSpec.describe "Responses", type: :request do
  # Teste 1: Resposta JSON Padrão
  it "retorna a resposta padrão em JSON usando a gem" do
    get "/my_action", headers: { "Accept" => "application/json" }

    json_response = JSON.parse(response.body)

    expect(json_response["status"]["name"]).to eq("OK")
    expect(json_response["status"]["code"]).to eq(200)
    expect(json_response["status"]["type"]).to eq("Success")
    expect(json_response["data"]["my_variable"]).to eq("Hello from FakeController")
  end

  # Teste 2: Tratamento de Exceções
  context "quando ocorre uma exceção" do
    before do
      allow_any_instance_of(FakesController).to receive(:my_action).and_raise(ActiveRecord::RecordNotFound,
                                                                              "Registro não encontrado")
    end

    it "captura ActiveRecord::RecordNotFound e retorna 404" do
      get "/my_action", headers: { "Accept" => "application/json" }

      json_response = JSON.parse(response.body)

      expect(response.status).to eq(404)
      expect(json_response["status"]["name"]).to eq("Not Found")
      expect(json_response["status"]["type"]).to eq("Client Error")
      expect(json_response["errors"]).to be_nil # Pode modificar para verificar uma mensagem de erro específica
    end
  end

  # Teste 3: Customização de Status e Mensagens
  context "quando o status de resposta é customizado" do
    it "customiza o status de resposta e retorna erros" do
      allow_any_instance_of(FakesController).to receive(:default_render).and_call_original
      get "/my_action_custom_status", headers: { "Accept" => "application/json" }

      json_response = JSON.parse(response.body)

      expect(response.status).to eq(422)
      expect(json_response["status"]["name"]).to eq("Unprocessable Content")
      expect(json_response["status"]["type"]).to eq("Client Error")
      expect(json_response["errors"].first["message"]).to eq("Dados inválidos")
    end
  end

  # Teste 4: Metadados de Paginação
  context "quando a resposta inclui metadados de paginação" do
    before do
      # Cria uma tabela temporária no banco de dados de teste
      ActiveRecord::Schema.define do
        create_table :temp_items, force: true do |t|
          t.string :name
          t.timestamps
        end
      end

      # Define a classe ActiveRecord temporária associada à tabela
      class TempItem < ActiveRecord::Base
        self.table_name = "temp_items"
      end

      # Popula a tabela temporária com dados
      25.times { |i| TempItem.create!(name: "Item #{i + 1}") }
    end

    it "inclui metadados de paginação na resposta JSON" do
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
      # Limpa a tabela e remove a classe temporária após o teste
      ActiveRecord::Schema.define do
        drop_table :temp_items, if_exists: true
      end
      Object.send(:remove_const, :TempItem) if defined?(TempItem)
    end
  end
end
