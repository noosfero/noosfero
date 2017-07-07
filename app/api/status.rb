module Api
  module Status
 
    module Http
      # HTTP Status
      BAD_REQUEST = 400
      UNAUTHORIZED = 401
      FORBIDDEN = 403
      NOT_FOUND = 404
      METHOD_NOT_ALLOWED = 405
      UNPROCESSABLE_ENTITY = 422
      OK = 200
      CREATED = 201
    end

    # Noosfero API Status
    DEPRECATED = 299
    module Membership
      INVITATION_SENT_TO_BE_PROCESSED = 298
      NOT_MEMBER = 297
      WAITING_FOR_APPROVAL = 296
      MEMBER = 295
    end

    module Friendship
      NOT_FRIEND = 294
      WAITING_FOR_APPROVAL = 293
      FRIEND = 292
    end

  end
end
