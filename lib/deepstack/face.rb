# frozen_string_literal: true

module Deepstack
  # APIs related to face recognition
  module Face
    #
    # Perform face recognition
    #
    # @param [Object] image binary data or a File object
    # @param [Hash] options additional fields for Deepstack, e.g. min_confidence: 0.5
    #
    # @return [Array] if successful, an array of Deepstack predictions
    #
    # @return [nil] if error
    #
    def recognize_faces(image, **options)
      target = 'vision/face/recognize'
      api_post(target, image, **options)
      predictions
    end

    #
    # Detect faces in an image
    #
    # @param [Object] image binary data or a File object
    # @param [Hash] options additional fields for Deepstack, e.g. min_confidence: 0.5
    #
    # @return [Array] if successful, an array of Deepstack predictions
    #
    def detect_faces(image, **options)
      target = 'vision/face/' # the URL ends with a slash
      api_post(target, image, **options)
      predictions
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
      api_post(target, userid: userid)
      success?
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
      api_post(target, images, userid: userid)
      success?
    end
  end
end
