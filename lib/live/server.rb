require 'sinatra/base'
#require 'sinatra_warden'
require 'rack/flash'
require 'live/auth'

module Live

  # = Facets Live! Sinatra-based Server
  #
  class Server < Sinatra::Base
    enable :sessions #use Rack::Session::Cookie
    use Rack::Flash

    include Authentication

    set :root, File.dirname(__FILE__)
    set :static, true

    #
    get '/' do
      @scripts_newest  = Script.newest
      @scripts_latest  = Script.latest
      @scripts_popular = Script.popular
      erb :index
    end
 
    # Sign up for new account.
    get '/register' do
      @title = "Sign Up"
      erb :register
    end

    # Sign up for new account.
    post '/register' do
      if params[:password] != params[:confirm]
        flash[:message] = "Oops! Could not confirm password."
        redirect(back)
      end

      @user = ::User.new

      @user.username  = params[:username]
      @user.name      = params[:name]
      @user.email     = params[:email]
      @user.website   = params[:website]

      @user.salt = Digest::SHA1.hexdigest("--#{Time.now.to_f}--#{@user.email}--")

      @user.password  = params[:password]

      if @user.save
        flash[:message] = 'Account created. Please sign-in.'
        redirect '/' #MainController.r(:index)
      end
    end

    get '/profile' do
      authorize!('/login')
      @title = 'Profile'
      erb :profile
    end

    #
    post '/profile' do
      authorize!('/login')

      if params[:password] != params[:confirm]
        flash[:message] = "Oops! Could not confirm new password."
        redirect(back)
      end

      user.name     = params[:name]
      user.email    = params[:email]
      user.website  = params[:website]

      user.username = params[:username] # TODO: remove
      user.password = params[:password] if params[:password] && !params[:password].empty?

      if user.save
        flash[:message] = 'Profile saved'
        redirect "/dashboard"
      end
    end

    #
    get '/login' do
      redirect(back) if authorized?
      @title = "Sign In"
      erb :login
    end

    #
    post '/login' do
      if authorized?
        flash[:message] = "Signed In" # TODO: NOT WORKING
        redirect '/dashboard'
      else
        @title = "Sign In"
        flash[:message] = "Invalid Credentials"
        erb :login
      end
    end

    #
    get '/logout' do
      self.user = nil
      flash[:message] = "Signed Out"
      redirect '/'
    end

    #
    post '/search' do
      @title    = "Search"
      @criteria = params[:criteria]
      if @criteria
        @scripts = Script.filter(:archive => nil, :name => /^#{@criteria}/i).order(:name).limit(25)
      else
        redirect '/browse/A'
      end
      erb :browse
    end

    #
    get '/browse/:letter' do
      @title  = "Browse"
      @letter = params[:letter]
      if @letter
        @scripts = Script.filter(:archive => nil, :name => /^#{@letter}/i).order(:name).limit(25)
      else
        @scripts = Script.filter(:archive => nil).order(:name).limit(25)
      end
      erb :browse
    end

    #
    get '/dashboard' do
      authorize!('/login') # must be logged-in

      @title     = "Dashboard"
      @scripts   = Script.filter(:archive => nil, :owner => user.username)
      @watchlist = Track.filter(:user_id => user_id, :watch => true) #.limit(20) #paginate?

      erb :dashboard
    end

    #
    get '/script/:id' do
      id = params[:id]
      @script = Script[:id=>id]
      @track  = Track[:user_id=>user_id, :owner=>@script.owner, :name=>@script.name]
      erb :script
    end

    #
    get '/script/:owner/:name' do
      owner = params[:owner]
      name  = params[:name]
      @script = Script[:archive=>nil, :owner=>owner, :name=>name]
      @track  = Track[:user_id=>user_id, :owner=>@script.owner, :name=>@script.name]
      erb :script
    end

    #
    get '/copy/:id/:name' do
      authorize!('/login')

      id   = params[:id]
      name = params[:name]

      script = Script[:name=>name,:owner=>user.username]
      if script
        flash[:message] = "ERROR! You already have a script named '#{name}'."
        redirect(back)
      else
        orig = Script[:id=>id]
        vals = orig.values.dup
        vals.delete(:id)
        copy = Script.create(vals)
        copy.name       = name
        copy.owner      = user.username
        copy.version    = 1
        copy.copy       = orig.id
        copy.rating     = 0
        copy.downloads  = 0
        copy.downloaded = Time.now #nil
        copy.created    = Time.now
        copy.archive    = nil
        copy.save
        @script = copy
        erb :edit
      end
    end

    # Create new script.
    get '/edit' do
      authorize!('/login')

      @script = Script.new(:owner=>user.username, :modifier=>user.username, :modified=>Time.now)
      erb :edit
    end

    # Edit script.
    get '/edit/:id' do
      authorize!('/login')

      id = params[:id]

      @script = Script[:id=>id]

      if user.username != @script.owner
        flash[:message] = "Unathorized Access!"
        redirect(back)
      else
        erb :edit
      end
    end

    #
    post '/edit' do
      authorize!('/login')

      id = params[:id]
      if id.empty?
        @script = Script.new(:owner=>user.username, :modifier=>user.username, :modified=>Time.now)
      else
        @script = Script[:id=>id]
        if user.username != @script.owner
          flash[:message] = "Unathorized Access!"
          redirect(back)
        end
      end

      @script[:name] = params[:name] if @script.new?
      @script[:code] = params[:code]
      @script[:test] = params[:test]
      @script[:description] = params[:desc]

      @script[:modifier] = user.username

      bump = (params[:bump] == 'true' ? true : false)

      if @script.save(bump)
        flash[:message] = 'Script saved'
        redirect "/script/#{@script.id}"
      else
        flash[:message] = 'Script error!'
        redirect "/edit"
      end
    end

    #
    get '/watch/:owner/:name' do
      authorize!('/login')

      owner = params[:owner]
      name  = params[:name]
      track = Track[:user_id=>user_id, :owner=>owner, :name=>name]
      unless track
        track = Track.new(:user_id=>user_id, :owner=>owner, :name=>name)
      end
      track.watch = true
      track.save
      redirect(back)
    end

    #
    get '/unwatch/:owner/:name' do
      authorize!('/login')

      owner = params[:owner]
      name  = params[:name]
      track = Track[:user_id=>user_id, :owner=>owner, :name=>name]
      unless track
        track = Track.new(:user_id=>user_id, :owner=>owner, :name=>name)
      end
      track.watch = false
      track.save
      redirect(back)
    end

    #
    get '/star/:id' do
      authorize!('/login')

      id = params[:id]

      script = Script[:id=>id]
      track  = script.track(user_id)
      #track = Track[:user_id=>user_id, :owner=>script.owner, :name=>script.name]
      unless track
        track = Track.new(:user_id=>user_id, :owner=>script.owner, :name=>script.name)
      end

      track.star = !track.star
      track.save

      'Starred!'
    end

    #
    get '/flag/:id' do
      authorize!('/login')

      id = params[:id]

      script = Script[:id=>id]
      track  = script.track(user_id)
      #track = Track[:user_id=>user_id, :owner=>script.owner, :name=>script.name]
      unless track
        track = Track.new(:user_id=>user_id, :owner=>script.owner, :name=>script.name)
      end

      track.flag = !track.flag
      track.save

      'Flagged!'
    end

    #
    get '/require/:user/:name' do
      user = params[:user]
      name = params[:name]
      Script[:user=>user, :name=>name, :archive=>nil].code
    end

    #
    get '/require/:user/:name/:vers' do
      user = params[:user]
      name = params[:name]
      vers = params[:vers]
      Script[:user=>user, :name=>name, :vers=>vers].code
    end

    #post '/set-flash' do
    #  # Set a flash entry
    #  flash[:notice] = "Thanks for signing up!"
    #
    #  # Get a flash entry
    #  flash[:notice] # => "Thanks for signing up!"
    #
    #  # Set a flash entry for only the current request
    #  flash.now[:notice] = "Thanks for signing up!"
    #end
  end

end

