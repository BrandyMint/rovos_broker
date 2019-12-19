# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

# Machines web controller (JSON)
#
#
# Использую haname-action только ради обработки ошибок
#
module Machines
  # Список подключенных машин
  class Index
    include Hanami::Action
    def call(_params)
      # self.headers.merge!({ 'X-Custom' => 'OK' })
      self.body = $tcp_server.connections.keys.to_json
    end
  end

  # Запрос на смену статуса машины
  class ChangeStatus
    include Hanami::Action
    def call(params)
      id = params[:id].to_i
      self.body = { result: $tcp_server.connections.fetch(id).set(params[:state].to_i, params[:time].to_i) }.to_json
    rescue KeyError
      self.status = 404
      self.body = "No such machine online #{id}"
    end
  end

  # Получение статуса машины
  class GetStatus
    include Hanami::Action
    def call(params)
      id = params[:id].to_i
      self.body = { result: $tcp_server.connections.fetch(id).get }.to_json
    rescue KeyError
      self.status = 404
      self.body = "No such machine online #{id}"
    end
  end
end
