# frozen_string_literal: true

require 'yaml'

def port # rubocop:disable Metrics/MethodLength
  # default ports to use unless overridden by the config file
  @ports ||= {
    defaults: true,
    no_auth: { http: 8001, https: 8002 },
    auth: { http: 8003, https: 8004 }
  }

  return @ports unless @ports[:defaults]

  @ports.delete(:defaults)
  config_file = 'rakelib/deepstack.yml'
  if File.file? config_file
    file = File.read(config_file)
    config = YAML.safe_load(file, symbolize_names: true)[:ports]
    @ports.merge!(config)
  end
  @ports
end
