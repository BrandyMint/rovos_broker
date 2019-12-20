# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

# Machines web controller (JSON)
#
#
# Использую haname-action только ради обработки ошибок
#
module Machines
  HEADERS = {'Content-Type' => 'application/json'}
  # Список подключенных машин
  class Index
    include Hanami::Action
    def call(_params)
      self.headers.merge! HEADERS
      self.body = { machines: $tcp_server.connections.keys }.to_json
    end
  end

  # Запрос на смену статуса машины
  class ChangeStatus
    include Hanami::Action
    def call(params)
      self.headers.merge! HEADERS
      connection = $tcp_server.connections.fetch params[:id].to_i
      sid = connection.channel.subscribe do |message|
        @_env['async.callback'].call [200, HEADERS, { response_message: message.to_h }.to_json ]
        connection.channel.unsubscribe sid
      end
      message = connection.build_message state: params[:state].to_i, work_time: params[:time].to_i
      connection.send_message message
      self.status = -1
      # self.body = { message: message.to_h, status: 'sent'  }.to_json
    rescue KeyError
      self.status = 404
      self.body = { error: "No such machine online" }.to_json
    end
  end

  # Получение статуса машины
  class GetStatus
    include Hanami::Action
    def call(params)
      connection = $tcp_server.connections.fetch params[:id].to_i
      self.headers.merge! HEADERS
      self.status = 200
      self.body = { machine_id: connection.machine_id, last_activity: connection.last_activity }.to_json
    rescue KeyError
      self.status = 404
      self.body = { error: "No such machine online" }.to_json
    end
  end
end
