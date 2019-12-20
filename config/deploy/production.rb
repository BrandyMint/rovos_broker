# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

# frozen_string_literal: true

set :stage, :production

server ENV['PRODUCTION_HOST'],
       user: fetch(:user),
       port: '22',
       roles: %w[broker].freeze,
       ssh_options: { forward_agent: true }
