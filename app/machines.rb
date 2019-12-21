# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

# Machines web controller (JSON)
#
#
# Использую haname-action только ради обработки ошибок
#
module Machines
  HEADERS = {
    'Content-Type' => 'application/json',
    'X-App-Version' => AppVersion.to_s,
    'X-App-Env' => ENV['RACK_ENV']
  }.freeze
  # Сборник утилит
  class Action
    private

    def fetch_connection(id)
      connection = $tcp_server.connections.fetch id.to_i
      yield connection
    rescue KeyError
      self.status = 404
      self.body = { error: 'No such machine online' }.to_json
    end
  end

  # Список подключенных машин
  class Index < Action
    include Hanami::Action

    def call(_params)
      headers.merge! HEADERS
      self.status = 200
      self.body = { env: ENV['RACK_ENV'], version: AppVersion.to_s, machines: $tcp_server.connections.keys }.to_json
    end
  end

  # Запрос на смену статуса машины
  class ChangeStatus < Action
    include Hanami::Action
    # rubocop:disable Metrics/AbcSize
    def call(params)
      headers.merge! HEADERS
      fetch_connection params[:id] do |connection|
        sent_message = connection.build_message state: params[:state].to_i, work_time: params[:work_time].to_i
        sid = connection.channel.subscribe do |message|
          @_env['async.callback'].call [201, HEADERS, { sent: sent_message.to_h, received: message.to_h }.to_json]
          connection.channel.unsubscribe sid
        end
        connection.send_message sent_message
        self.status = -1
      end
    end
    # rubocop:enable Metrics/AbcSize
  end

  # Получение статуса машины
  class GetStatus < Action
    include Hanami::Action
    def call(params)
      headers.merge! HEADERS
      fetch_connection params[:id] do |connection|
        self.status = 200
        self.body = {
          machine_id: connection.machine_id,
          last_activity_at: connection.last_activity,
          last_activity_elapsed: Time.now - connection.last_activity
        }.to_json
      end
    end
  end
end
