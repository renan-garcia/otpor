# Otpor

A gem `otpor` foi desenvolvida para auxiliar no desenvolvimento de aplicações API em Rails, padronizando as respostas JSON. Ela facilita o tratamento de exceções, a customização de status e mensagens de erro, e a inclusão de metadados como paginação nas respostas.


## Instalação

Adicionando em sua Gemfile:

```ruby
gem 'otpor'
```

Ou instale você mesmo:

    $ gem install otpor

## Exemplos de uso
### Em seu controlador
#### Inclua o módulo `Otpor::JsonResponse` em seu controlador

```ruby
    class FakesController < ApplicationController
        include Otpor::JsonResponse

        def my_action
            @my_variable = "Hello from FakeController"
            render json: { my_variable: @my_variable }
        end
    end
```

### Tratamento de exceções

```ruby
    class FakesController < ApplicationController
        include Otpor::JsonResponse

        def my_action
            raise ActiveRecord::RecordNotFound, "Registro não encontrado"
        end
    end
```

### Teste RSpec
    
```ruby
    RSpec.describe "Responses", type: :request do
        it "retorna a resposta padrão em JSON usando a gem" do
            get "/my_action", headers: { "Accept" => "application/json" }

            json_response = JSON.parse(response.body)

            expect(json_response["status"]["name"]).to eq("OK")
            expect(json_response["status"]["code"]).to eq(200)
            expect(json_response["status"]["type"]).to eq("Success")
            expect(json_response["data"]["my_variable"]).to eq("Hello from FakeController")
        end
    end

    RSpec.describe "Responses", type: :request do
        context "quando ocorre uma exceção" do
            before do
                allow_any_instance_of(FakesController).to receive(:my_action).and_raise(ActiveRecord::RecordNotFound, "Registro não encontrado")
            end

            it "captura ActiveRecord::RecordNotFound e retorna 404" do
                get "/my_action", headers: { "Accept" => "application/json" }

                json_response = JSON.parse(response.body)

                expect(response.status).to eq(404)
                expect(json_response["status"]["name"]).to eq("Not Found")
                expect(json_response["status"]["type"]).to eq("Client Error")
                expect(json_response["errors"]).to be_nil
            end
        end
    end
```

### Coustomizando status e mensagens de erro

```ruby
    class FakesController < ApplicationController
        include Otpor::JsonResponse

        def my_action
            raise ActiveRecord::RecordNotFound, "Registro não encontrado"
        end

        def my_custom_action
            render_error(status: 400, type: "Client Error", name: "Bad Request", message: "Requisição inválida")
        end
    end
```

### Metadados de paginação

```ruby
    class FakesController < ApplicationController
        include Otpor::JsonResponse

        def my_action_pagination
            items = TempItem.page(params[:page]).per(10)
            @meta = {
            pagination: {
                total_pages: items.total_pages,
                total_count: items.total_count,
                current_page: items.current_page,
                next_page: items.next_page,
                prev_page: items.prev_page,
                per_page: items.limit_value
            }
            }
            render json: items
        end
    end
```
    

# Developers

[Renan Garcia](https://github.com/renan-garcia),
[Henrique Max](https://github.com/rickmax)

## Como contribuir?

1. Faça um fork do projeto;
1. Adicione os devidos ajustes ou melhorias com os respectivos testes;
1. Envie pull request;


## Licença

Está Gem esta disponível sob os termos de licença [MIT License](http://opensource.org/licenses/MIT).
