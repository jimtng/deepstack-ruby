# frozen_string_literal: true

require 'rake'
require 'deepstack'
require 'yaml'
require 'pp'

Rake.application.rake_require 'docker_support', ['rakelib']

# http internal is used in persistence check below
class DeepStack
  attr_reader :http
end

def deepstack_baseurl(port)
  "http://127.0.0.1:#{port}"
end

def deepstack
  @deepstack ||= DeepStack.new(deepstack_baseurl(deepstack_port))
end

def auth_deepstack
  @auth_deepstack ||= DeepStack.new(deepstack_baseurl(deepstack_port_with_auth), api_key: 'myapikey',
                                                                                 admin_key: 'myadminkey')
end

# rubocop:disable Metrics/BlockLength
RSpec.describe DeepStack do
  image = File.read('spec/test_images/person-dog.jpg')

  context 'Basic Usage' do
    it 'can be initialized with a url' do
      expect(deepstack).not_to be_nil
    end

    it 'can close and reopen its http connection' do
      result = deepstack.face_list
      expect(result).to be_an Array
      expect(deepstack.http.started?).to be true
      deepstack.close
      expect(deepstack.http.started?).to be false
      result = deepstack.face_list
      expect(deepstack.http.started?).to be true
      expect(result).to be_an Array
      expect(deepstack.http.started?).to be true
    end

    it 'can work with an api key' do
      result = auth_deepstack.detect_objects(image)
      expect(result).to be_an Array
    end
  end

  context 'Object Detection' do
    it 'can detect objects' do
      result = deepstack.detect_objects(image)
      # pp result
      expect(result).to be_an Array
      expect(result.size).to be > 0
      expect(result.first).to be_a Hash
      expect(result.first.keys).to include(*%w[confidence label x_max x_min y_max y_min])
    end
  end

  context 'Face Detection' do
    it 'can detect faces' do
      result = deepstack.detect_faces(image)
      # pp result
      expect(result).to be_an Array
      expect(result.first).to be_a Hash
      expect(result.first.keys).to include(*%w[confidence x_min y_min x_max y_max])
    end
  end

  context 'Face Recognition' do
    it 'can return a list of registered faces' do
      faces = deepstack.face_list
      expect(faces).to be_an Array
    end

    it 'can register a face with one image object' do
      # image = File.read('spec/test_images/idriselba3.jpeg')
      result = deepstack.register_face('user1', image)
      expect(result).to be true

      faces = deepstack.face_list
      expect(faces).to include 'user1'
    end

    it 'can register a face given a File object of an image file' do
      result = File.open('spec/test_images/person-dog.jpg') do |img|
        deepstack.register_face('user2', img)
      end
      expect(result).to be true

      faces = deepstack.face_list
      expect(faces).to include 'user2'
    end

    it 'can register a face with multiple image objects' do
      face_count_before = deepstack.face_list.size
      images = []
      images << File.read('spec/test_images/person-dog.jpg')
      images << File.read('spec/test_images/person-dog.jpg')
      images << File.read('spec/test_images/person-dog.jpg')

      result = deepstack.register_face('user3', images)
      expect(result).to be true

      faces = deepstack.face_list
      expect(faces).to include 'user3'
      expect(faces.size).to be > face_count_before
    end

    it 'can recognize faces from an image' do
      result = deepstack.recognize_faces(image)
      # pp result
      expect(result).to be_an Array
      expect(result.first.keys).to include(*%w[confidence userid x_min y_min x_max y_max])
    end

    it 'can delete a registered face' do
      face_count_before = deepstack.face_list.size
      result = deepstack.delete_face('user1')
      expect(result).to be true
      expect(deepstack.face_list.size).to be < face_count_before
    end

    it 'can delete all registered faces' do
      faces = deepstack.face_list
      expect(faces.size).to be > 0
      result = deepstack.delete_faces(faces)
      expect(result).to be_a Hash
      faces = deepstack.face_list
      expect(faces.size).to eq 0
    end

    it 'can perform face matching' do
      image2 = image
      result = deepstack.face_match(image, image2)
      expect(result).to be_a_kind_of(Numeric)
    end
  end

  context 'Scene Recognition' do
    it 'can detect scene' do
      result = deepstack.identify_scene(image)
      expect(result).to be_a Hash
      # pp result
      expect(result.keys).to include(*%w[confidence label])
    end
  end

  context 'Custom Model' do
    it 'can use a custom model' do
      result = deepstack.custom_model('combined', image)
      expect(result).to be_an Array
    end
  end
end
# rubocop:enable Metrics/BlockLength
