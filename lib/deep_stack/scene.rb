# frozen_string_literal: true

class DeepStack
  # Scene Recognition
  module Scene
    #
    # Call the scene recognition API to classify an image into one of the supported scenes.
    #
    # @param [Object] image binary data or a File object
    # @param [Hash] options additional fields for DeepStack, e.g. min_confidence: 0.5
    #
    # @return [Hash] if successful, DeepStack result hash +{'label' => 'scene', 'confidence' => 2.2}+
    #
    # @return [nil] if error
    #
    def identify_scene(image, **options)
      target = 'vision/scene'
      api_post(target, image, **options)
    end
  end
end
