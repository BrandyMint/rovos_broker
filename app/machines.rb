# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

# Machines web controller (JSON)
#
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
      id = params[:id].to_i
      minutes = params[:minutes].to_i
      minutes = 4 if minutes == 0
      self.body = MACHINE_CONNECTIONS.fetch(id).start(minutes)
    rescue KeyError
      self.status = 404
      self.body = "No such machine online #{id}"
    end
  end

  class Status
    include Hanami::Action
    def call(params)
      id = params[:id].to_i
      self.body = MACHINE_CONNECTIONS.fetch(id).status
    rescue KeyError
      self.status = 404
      self.body = "No such machine online #{id}"
    end
  end
end
