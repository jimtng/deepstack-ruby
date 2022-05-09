# frozen_string_literal: true

require 'yaml'

def deepstack_port
  config_file = 'rakelib/deepstack.yml'
  return 81 unless File.file? config_file

  YAML.load_file(config_file)&.dig('deepstack_port') || 81
end

# rubocop: disable Metrics/BlockLength
namespace :deepstack do
  @docker_image = 'deepquestai/deepstack:cpu-2021.09.1'
  @image_name = 'deepstack_ruby_test'

  def deepstack_running?
    `(docker ps | grep -q #{@image_name}) && echo running`.chomp == 'running'
  end

  desc 'Start deepstack test docker'
  task :start do
    next if deepstack_running?

    puts 'Starting DeepStack docker...'
    cmd = %(
      docker run
          --name #{@image_name}
          --rm
          -d
          -e VISION-FACE=True
          -e VISION-DETECTION=True
          -e VISION-SCENE=True
          -e MODE=Low
          -p #{deepstack_port}:5000
          #{@docker_image}).gsub(/\s+/, ' ').strip
    `#{cmd}`
  end

  desc 'Stop deepstack test docker'
  task :stop do
    puts 'Stopping DeepStack docker...'
    `docker stop #{@image_name}` if deepstack_running?
  end
end
# rubocop: enable Metrics/BlockLength
