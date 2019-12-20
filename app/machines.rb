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
      self.body = { machines: $tcp_server.connections.keys }.to_json
    end
  end

  # Запрос на смену статуса машины
  class ChangeStatus
    include Hanami::Action
    def call(params)
      connection = $tcp_server.connections.fetch params[:id].to_i
      message = connection.build_message state: params[:state].to_i, work_time: params[:time].to_i
      connection.send_message message
      self.body = { message: message, status: 'sent'  }.to_json
    rescue KeyError
      self.status = 404
      self.body = "No such machine online #{id}"
    end
  end

  # Получение статуса машины
  class GetStatus
    include Hanami::Action
    def call(params)
      connection = $tcp_server.connections.fetch params[:id].to_i

      cb = Proc.new do |message|
        connection.query = nil
        @_env['async.callback'].call [200, {'Content-Type' => 'application/json'}, { response_message: message }.to_jso ]
      end
      connection.query = EM::Queue.new
      connection.query.pop(&cb)

      connection.send_message connection.build_message state: 4
      self.status = -1
    rescue KeyError
      self.status = 404
      self.body = "No such machine online #{id}"
    end
  end
end
