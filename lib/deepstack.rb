# frozen_string_literal: true

require 'pp'
require 'net/http'
require 'json'
require_relative 'deepstack/face'
require_relative 'deepstack/detection'
require_relative 'deepstack/scene'
require_relative 'deepstack/custom'
require_relative 'deepstack/version'

# DeepStack API
class DeepStack
  include DeepStackModule::Face
  include DeepStackModule::Detection
  include DeepStackModule::Scene
  include DeepStackModule::Custom

  attr_reader :duration, :predictions, :success

  # Create a deepstack object connected to the given URL
  def initialize(base_url)
    @base_url = base_url
  end

  #
  # The result of the last call
  #
  # @return [Boolean] true if the last call was successful
  #
  def success?
    @success == true
  end

  #
  # Make a POST request to DeepStack path target
  #
  # @param [String] path to the DeepStack API URL
  # @param [Array] images zero or more images to post
  # @param [Hash] args additional named fields to post
  #
  # @return [Hash] if successful, the json data returned by DeepStack, nil otherwise
  #
  def api_post(path, *images, **args)
    uri = build_uri(path)

    result = nil
    10.times do
      result = images ? post_files(uri, images.flatten, **args) : post(uri, args)
      break unless result.is_a?(Net::HTTPRedirection)

      uri.path = result['location']
    end
    raise Net::HTTPClientException, 'Too many redirections' if result.is_a?(Net::HTTPRedirection)

    process_result(result)
  end

  private

  def build_uri(path)
    URI.join(@base_url, '/v1/', path)
  end

  def post(uri, **args)
    Net::HTTP.post_form(uri, args)
  end

  def post_files(uri, *images, **args)
    form_data = combine_images_and_args(images.flatten, **args)
    req = Net::HTTP::Post.new(uri)
    req.set_form(form_data, 'multipart/form-data')
    Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
  end

  def combine_images_and_args(*images, **args)
    stringify_keys(args).concat(image_form_data(images.flatten))
  end

  def stringify_keys(hash)
    hash.map { |k, v| [k.to_s, v] }
  end

  #
  # Return an array of image entries for form data.
  # The field name is 'image' for a single image
  # For multiple images, the field names will be 'image1', 'image2', ...
  #
  # @param [Array<Object>] images an array of raw image data or a File object
  #
  # @return [Array] the image entries for set_form
  #
  def image_form_data(*images)
    images = images.flatten
    return [image_entry('image', images.first)] if images.length == 1

    images.map.with_index(1) { |image, i| image_entry("image#{i}", image) }
  end

  def image_entry(name, image)
    [name, image].tap { |result| result << { filename: "#{name}.jpg" } unless image.instance_of? File }
  end

  def process_result(result)
    @result = result.is_a?(Net::HTTPSuccess) ? JSON.parse(result.body) : nil
    %w[success duration predictions].each { |attrib| instance_variable_set("@#{attrib}", @result&.dig(attrib)) }
    @result
  end
end
