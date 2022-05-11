# frozen_string_literal: true

require 'yaml'

# rubocop: disable Metrics/BlockLength
namespace :deepstack do
  @docker_image = 'deepquestai/deepstack:cpu-2021.09.1'

  def deepstack_running?(name)
    `(docker ps | grep -q #{name}) && echo running`.chomp == 'running'
  end

  def start_deepstack(name, port, **args) # rubocop:disable Methics/MethodLength
    cmd = %(
      docker run
          --name #{name}
          --rm
          #{to_cli(args)}
          -d
          -e VISION-FACE=True
          -e VISION-DETECTION=True
          -e VISION-SCENE=True
          -e MODE=Low
          -p #{port}:5000
          #{@docker_image}).gsub(/\s+/, ' ').strip
    `#{cmd}`
  end

  def to_cli(args)
    args.select { |_k, v| v }.map do |key, val|
      "-e #{key.to_s.upcase.sub("_", "-")}=#{val}"
    end.join(' ')
  end

  desc 'Start deepstack test docker'
  task :start do
    puts 'Starting DeepStack docker...'
    auth = { api_key: 'myapikey', admin_key: 'myadminkey' }
    start_deepstack('deepstack_test1', deepstack_port) unless deepstack_running?('deepstack_test1')
    start_deepstack('deepstack_test2', deepstack_port_with_auth, **auth) unless deepstack_running?('deepstack_test2')
  end

  desc 'Stop deepstack test docker'
  task :stop do
    puts 'Stopping DeepStack docker...'
    %w[deepstack_test1 deepstack_test2].each do |image_name|
      `docker stop #{image_name}` if deepstack_running?(image_name)
    end
  end
end
# rubocop: enable Metrics/BlockLength
