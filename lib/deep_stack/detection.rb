# frozen_string_literal: true

class DeepStack
  # APIs related to object detection
  module Detection
    #
    # Perform object detection
    #
    # @param [Object] image raw image data or a File object of an image file
    # @param [Hash] options additional fields for DeepStack, e.g. min_confidence: 0.5
    #
    # @return [Array] a list of predictions, or nil on error
    #
    def detect_objects(image, **options)
      target = 'vision/detection'
      api_post(target, image, **options)
      predictions
    end
  end
end
