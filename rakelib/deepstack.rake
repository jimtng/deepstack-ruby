# frozen_string_literal: true

require 'open-uri'

# rubocop: disable Metrics/BlockLength
namespace :deepstack do
  # @docker_image = 'deepquestai/deepstack:cpu-2021.09.1'
  @docker_image = 'deepquestai/deepstack:cpu-2022.01.1'

  def deepstack_running?(name)
    `(docker ps | grep -q #{name}) && echo running`.chomp == 'running'
  end

  def tmp_dir(subdir = nil)
    Dir.mkdir(TMP_DIR) unless Dir.exist? TMP_DIR
    "#{TMP_DIR}/#{subdir}".tap { |dir| Dir.mkdir(dir) unless Dir.exist?(dir) }
  end

  def start_deepstack(name, port, ssl: false, **args) # rubocop:disable Metrics/MethodLength
    return if deepstack_running? name

    internal_port = 5000
    if ssl
      internal_port = 443
      cert = "-v #{TMP_DIR}/cert:/cert"
    end
    cmd = %(
      docker run
          --name #{name}
          --rm
          #{to_cli(args)}
          -d
          -e VISION-FACE=True
          -e VISION-DETECTION=True
          -e VISION-SCENE=True
          -e VISION-ENHANCE=True
          -e MODE=Low
          -v #{TMP_DIR}/models:/modelstore/detection
          #{cert}
          -p #{port}:#{internal_port}
          #{@docker_image}).gsub(/\s+/, ' ').strip
    `#{cmd}`
  end

  def to_cli(args)
    args.select { |_k, v| v }.map do |key, val|
      "-e #{key.to_s.upcase.sub("_", "-")}=#{val}"
    end.join(' ')
  end

  desc 'Download custom model'
  task :download_model do
    models_dir = tmp_dir('models')

    uri = URI('https://github.com/MikeLud/DeepStack-Security-Camera-Models/raw/main/Models/combined.pt')
    output_file = "#{models_dir}/#{File.basename(uri.path)}"
    next if File.exist? output_file

    puts 'Downloading custom models...'
    File.open(output_file, 'w') { |file| uri.open { |data| file.write data.read } }
  end

  desc 'Generate a self signed certificate'
  task :cert do
    cert_path = tmp_dir('cert')
    key = "#{cert_path}/key.pem"
    cert = "#{cert_path}/fullchain.pem"
    next if File.exist?(key) && File.exist?(cert)

    cmd = %(
      openssl req
        -x509 -newkey rsa:4096 -sha256 -days 365 -nodes -subj '/CN=localhost'
        -keyout #{key}
        -out #{cert}
    ).gsub(/\s+/, ' ').strip
    `#{cmd}`
  end

  desc 'Start deepstack test docker'
  task start: %i[cert download_model] do
    puts 'Starting DeepStack docker...'
    auth = { api_key: 'myapikey', admin_key: 'myadminkey' }
    start_deepstack('deepstack_test_noauth', port[:no_auth][:http])
    start_deepstack('deepstack_test_auth', port[:auth][:http], **auth)
    start_deepstack('deepstack_test_ssl', port[:no_auth][:https], ssl: true)
  end

  desc 'Stop deepstack test docker'
  task :stop do
    puts 'Stopping DeepStack docker...'
    %w[deepstack_test_noauth deepstack_test_auth deepstack_test_ssl].each do |image_name|
      `docker stop #{image_name}` if deepstack_running?(image_name)
    end
  end
end
# rubocop: enable Metrics/BlockLength
