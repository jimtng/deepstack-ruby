# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

PACKAGE_DIR = 'pkg'
TMP_DIR = File.expand_path('tmp')

RSpec::Core::RakeTask.new(:spec)

CLEAN << PACKAGE_DIR
CLEAN << TMP_DIR

task default: %i[deepstack:start spec]
