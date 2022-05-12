# frozen_string_literal: true

require 'base64'

class DeepStack
  # Support Image Enhance feature
  module Image
    #
    # Enhance image {https://docs.deepstack.cc/api-reference/index.html#image-enhance}
    #
    # @param [Image] image the raw image data or a File object of an image file
    #
    # @return [Image] the enhanced image object
    # @return [nil] if failed
    #
    def enhance_image(image)
      target = 'vision/enhance'
      result = api_post(target, image)
      return unless result&.dig('success') == true

      Base64.decode64(result['base64'])
    end
  end
end
