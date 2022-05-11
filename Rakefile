# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

TMP_DIR = File.expand_path('tmp')

RSpec::Core::RakeTask.new(:spec)

task default: %i[deepstack:start spec]
