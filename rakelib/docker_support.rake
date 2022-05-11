# frozen_string_literal: true

def deepstack_port
  config_file = 'rakelib/deepstack.yml'
  default = 81
  return default unless File.file? config_file

  YAML.load_file(config_file)&.dig('deepstack_port') || default
end

def deepstack_port_with_auth
  config_file = 'rakelib/deepstack.yml'
  default = 82
  return default unless File.file? config_file

  YAML.load_file(config_file)&.dig('deepstack_port_with_auth') || default
end
