module Live

  # Helper methods for authentication.
  module Authentication

    #
    def user_id
      session[:user_id]
    end

    #
    def user
      @_user ||= user_id ? User[:id=>user_id] : nil
    end

    # Set the currently logged in user.
    #
    #   self.user = @user
    #
    def user=(user)
      session[:user_id] = user ? user.id : nil
    end

    #
    def authorized?
      return true if user_id
      username = params[:username]
      password = params[:password]
      user = User.authenticate(username, password)
      if user
        self.user = user
      end
      return user
    end
    alias_method :logged_in?, :authorized?

    # Require authorization for an action
    def authorize!(failpath=nil)
      unless authorized?
        redirect(failpath || '/login')
      end
    end

  end

end

