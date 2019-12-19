# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

module Machines
  # HEADERS = {"Content-Type" => "application/json"}
  class Index
    include Hanami::Action
    def call(_params)
      # self.headers.merge!({ 'X-Custom' => 'OK' })
      self.body = MACHINE_CONNECTIONS.keys.to_json
    end
  end

  class Start
    include Hanami::Action
    def call(params)
      puts params[:id]
      self.body = 'ok'
    end
  end

  class Status
    include Hanami::Action
    def call(params)
      id = params[:id].to_i
      self.body = MACHINE_CONNECTIONS.fetch(id).status
    rescue KeyError
      self.status = 404
      self.body = "No such machine found #{id}"
    end
  end
end
