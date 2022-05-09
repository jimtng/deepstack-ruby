# frozen_string_literal: true

require 'deepstack'
require 'yaml'
require 'pp'

def deepstack_port
  config_file = 'rakelib/deepstack.yml'
  return 81 unless File.file? config_file

  YAML.load_file(config_file)&.dig('deepstack_port') || 81
end

def deepstack_baseurl
  "http://127.0.0.1:#{deepstack_port}"
end

def deepstack
  @deepstack ||= DeepStack.new(deepstack_baseurl)
end

# rubocop:disable Metrics/BlockLength
RSpec.describe DeepStack do
  context 'Basic Usage' do
    it 'has a version number' do
      expect(DeepStack::VERSION).not_to be_nil
    end

    it 'can be initialized with a url' do
      expect(deepstack).not_to be_nil
    end
  end

  context 'Object Detection' do
    it 'can detect objects' do
      image = File.read('spec/test_images/person-dog.jpg')
      result = deepstack.detect_objects(image)
      # pp result
      expect(deepstack.success).not_to be_nil
      expect(result).to be_an Array
      expect(result.size).to be > 0
      expect(result.first).to be_a Hash
      expect(result.first.keys).to include(*%w[confidence label x_max x_min y_max y_min])
    end
  end

  context 'Face Detection' do
    it 'can detect faces' do
      image = File.read('spec/test_images/person-dog.jpg')
      result = deepstack.detect_faces(image)
      # pp result
      expect(deepstack.success).not_to be_nil
      expect(result).to be_an Array
      expect(result.first).to be_a Hash
      expect(result.first.keys).to include(*%w[confidence x_min y_min x_max y_max])
    end
  end

  context 'Face Recognition' do
    it 'can return a list of registered faces' do
      faces = deepstack.face_list
      expect(deepstack.success).not_to be_nil
      expect(faces).to be_an Array
    end

    it 'can register a face with one image object' do
      image = File.read('spec/test_images/person-dog.jpg')
      # image = File.read('spec/test_images/idriselba3.jpeg')
      deepstack.register_face('user1', image)
      expect(deepstack.success).to be true

      faces = deepstack.face_list
      expect(faces).to include 'user1'
    end

    it 'can register a face given a File object of an image file' do
      File.open('spec/test_images/person-dog.jpg') do |image|
        deepstack.register_face('user2', image)
      end
      expect(deepstack.success).to be true

      faces = deepstack.face_list
      expect(faces).to include 'user2'
    end

    it 'can register a face with multiple image objects' do
      face_count_before = deepstack.face_list.size
      images = []
      images << File.read('spec/test_images/person-dog.jpg')
      images << File.read('spec/test_images/person-dog.jpg')
      images << File.read('spec/test_images/person-dog.jpg')

      deepstack.register_face('user3', images)
      expect(deepstack.success).to be true

      faces = deepstack.face_list
      expect(faces).to include 'user3'
      expect(faces.size).to be > face_count_before
    end

    it 'can recognize faces from an image' do
      image = File.read('spec/test_images/person-dog.jpg')
      result = deepstack.recognize_faces(image)
      expect(deepstack.success).to be true
      # pp result
      expect(result).to be_an Array
      expect(result.first.keys).to include(*%w[confidence userid x_min y_min x_max y_max])
    end

    it 'can delete a registered face' do
      face_count_before = deepstack.face_list.size
      deepstack.delete_face('user1')
      expect(deepstack.success).to be true
      expect(deepstack.face_list.size).to be < face_count_before
    end

    it 'can delete all registered faces' do
      faces = deepstack.face_list
      expect(faces.size).to be > 0
      deepstack.delete_faces(faces)
      expect(deepstack.success).to be true
      faces = deepstack.face_list
      expect(faces.size).to eq 0
    end
  end

  context 'Scene Recognition' do
    it 'can detect scene' do
      image = File.read('spec/test_images/person-dog.jpg')
      result = deepstack.identify_scene(image)
      expect(deepstack.success).to be true
      # pp result
      expect(result.keys).to include(*%w[confidence label])
    end
  end
end
# rubocop:enable Metrics/BlockLength
