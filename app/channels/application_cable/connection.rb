module ApplicationCable
  class Connection < ActionCable::Connection::Base

    identified_by :current_user

    def connect
      self.current_user =
        if request.headers['Authorization'] == "Bearer foo"
          :publisher
        else
          :subscriber
        end

      logger.add_tags self.current_user
    end

    def allow_request_origin?
      if request.headers['Authorization']
        true
      else
        super
      end
    end

  end
end
