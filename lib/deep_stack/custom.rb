# frozen_string_literal: true

class DeepStack
  # Custom Model
  module Custom
    #
    # Register a custom inference method for convenience.
    # The custom method is called "identify_<modelname>"
    # Example:
    #   deepstack.register_custom_model('license_plate')
    #   deepstack.identify_license_plate(image)
    #
    # @param [Array] models a list of one or more custom model names to register
    #
    # @return [<Type>] <description>
    #
    def self.register_model(*models)
      models.flatten.each do |model|
        method_name = 'identify_'.concat model.gsub(/-+/, '_') # convert - to _
        define_method(method_name) do |image, **options|
          custom_inference(model, image, options)
        end
      end
    end

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
    def custom_inference(model, image, **options)
      target = "vision/custom/#{model}"
      api_post(target, image, options)&.dig('predictions')
    end
  end
end
