# frozen_string_literal: true

class DeepStack
  # Custom Model
  module CustomModel
    #
    # Return predictions using a custom model
    #
    # @param [String] model custom model name
    # @param [Object] image binary data or a File object
    # @param [Hash] options additional fields for DeepStack, e.g. min_confidence: 0.5
    #
    # @return [Array] if successful, an array of DeepStack predictions
    #
    # @return [nil] if error
    #
    def custom_model(model, image, **options)
      target = "vision/custom/#{model}"
      api_post(target, image, **options)&.dig('predictions')
    end
    # @deprecated Use {custom_model} instead
    alias custom_inference custom_model
  end
end
