# frozen_string_literal: true

class DeepStack
  # APIs related to face recognition
  module Face
    #
    # Perform face recognition
    #
    # @param [Object] image binary data or a File object
    # @param [Hash] options additional fields for DeepStack, e.g. min_confidence: 0.5
    #
    # @return [Array] if successful, an array of DeepStack predictions
    #
    # @return [nil] if error
    #
    def recognize_faces(image, **options)
      target = 'vision/face/recognize'
      api_post(target, image, **options)&.dig('predictions')
    end

    #
    # Detect faces in an image
    #
    # @param [Object] image binary data or a File object
    # @param [Hash] options additional fields for DeepStack, e.g. min_confidence: 0.5
    #
    # @return [Array] if successful, an array of DeepStack predictions
    #
    def detect_faces(image, **options)
      target = 'vision/face/' # the URL ends with a slash
      api_post(target, image, **options)&.dig('predictions')
    end

    #
    # Get a list of registered faces
    #
    # @return [Array] a list of userids
    #
    def face_list
      target = 'vision/face/list'
      api_post(target)&.dig('faces')
      # {"success"=>true, "faces"=>["face_1", "face_2"], "duration"=>0}
    end

    #
    # Delete the given list of faces / userids
    #
    # @param [Array] userids a list of userids to delete
    #
    # @return [Hash] A hash of `userid => boolean` that indicates success/failure
    #
    def delete_faces(*userids)
      userids.flatten.compact.to_h { |userid| [userid, delete_face(userid)] }
    end

    #
    # Delete the given face / userid
    #
    # @param [String] userid to delete
    #
    # @return [Boolean] true when successful
    #
    def delete_face(userid)
      target = 'vision/face/delete'
      api_post(target, userid: userid)&.dig('success') == true
    end

    #
    # Register a face
    #
    # @param [String] userid to register
    # @param [Array] images facial image data in binary form or File object
    #
    # @return [Boolean] true when successful
    #
    def register_face(userid, *images)
      target = 'vision/face/register'
      api_post(target, images, userid: userid)&.dig('success') == true
    end

    #
    # Call DeepStack's Face Match service. Compare two different pictures and tells the similarity between them.
    #
    # @example
    #   image1 = File.read('obama1.jpg')
    #   image2 = File.read('obama2.jpg')
    #   puts deepstack.face_match(image1, image2) > 0.6 ? 'similar' : 'different'
    #
    # @param [Array] *images two images to compare
    # @param [kwargs] **args optional arguments to the API call
    #
    # @return [Float] The similarity score (0-1)
    # @return [nil] if failed
    #
    def face_match(*images, **args)
      target = 'vision/face/match'
      api_post(target, images, **args)&.dig('similarity')
    end
  end
end
