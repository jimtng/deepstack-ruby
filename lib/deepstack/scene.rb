# frozen_string_literal: true

module Deepstack
  # Scene Recognition
  module Scene
    #
    # Return
    #
    # @param [Object] image binary data or a File object
    # @param [Hash] options additional fields for Deepstack, e.g. min_confidence: 0.5
    #
    # @return [Hash] if successful, Deepstack result hash {'label' => 'scene', 'confidence' => 2.2}
    #
    # @return [nil] if error
    def identify_scene(image, **options)
      target = 'vision/scene'
      api_post(target, image, **options)
    end
  end
end
