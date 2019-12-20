# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

# Machines web controller (JSON)
#
#
# Использую haname-action только ради обработки ошибок
#
module Machines
  HEADERS = { 'Content-Type' => 'application/json' }.freeze
  # Список подключенных машин
  class Index
    include Hanami::Action
    def call(_params)
      headers.merge! HEADERS
      self.body = { machines: $tcp_server.connections.keys }.to_json
    end
  end

  # Запрос на смену статуса машины
  class ChangeStatus
    include Hanami::Action
    def call(params)
      headers.merge! HEADERS
      connection = $tcp_server.connections.fetch params[:id].to_i
      sid = connection.channel.subscribe do |message|
        @_env['async.callback'].call [200, HEADERS, { response_message: message.to_h }.to_json]
        connection.channel.unsubscribe sid
      end
      connection.send_message connection.build_message state: params[:state].to_i, work_time: params[:time].to_i
      self.status = -1
    rescue KeyError
      self.status = 404
      self.body = { error: 'No such machine online' }.to_json
    end
  end

  # Получение статуса машины
  class GetStatus
    include Hanami::Action
    def call(params)
      connection = $tcp_server.connections.fetch params[:id].to_i
      headers.merge! HEADERS
      self.status = 200
      self.body = {
        machine_id: connection.machine_id,
        last_activity_at: connection.last_activity,
        last_activity_elapsed: Time.now - connection.last_activity
      }.to_json
    rescue KeyError
      self.status = 404
      self.body = { error: 'No such machine online' }.to_json
    end
  end
end
