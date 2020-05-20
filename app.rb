class App < Sinatra::Base
  require 'net/http'
  require 'json'
  require 'sinatra'
  require './models/init.rb'
  include FileUtils::Verbose

  configure do 
    enable :logging
    enable :sessions
    set :sessions_fail, '/'
    set :sessions_secret, "inhakiable papuuu"
    set :sessions_fail, true
  end 

  before do 
    @path = request.path_info
    #logger.info(session[:user_id])
    #logger.info(session[:user_name])
    if !session[:user_id] && @path != '/login' && @path != '/signUp'
      redirect '/login'
    elsif session[:user_id]
      @user = User.find(id: session[:user_id])
      #logger.info(@user.name);
    end
  end

  get "/" do
    #@user = User.find(id: session[:user_id])
    erb :index
  end

  post '/signUp' do
    request.body.rewind 
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json 
    user = User.new(name: params['name'], lastname: params['lastname'], dni: params['dni'], email: params['email'],password: params['pwd'] )
    
    if user.save
      redirect '/login'
      #user.last
    else
      [401,{},"no esta guardado papuu"]
    end 
  end

  get '/signUp' do
    if session[:user_id]
      session.clear
    end
    erb :signUp
  end

  get '/log_out' do
    if session[:user_id]
      session.clear
    end
    redirect '/'
  end

  get '/save_document' do 
    erb :save_document
  end

  post '/save_document' do
   
    file = params[:fileInput] [:tempfile]
    @fileName = params["title"]
    @fileFormat = File.extname(file)
    @directory = "public/files/"
    document = Document.new(title: @fileName, type: params["type"], format:@fileFormat, visibility: true, user_id: session[:user_id], path: "")
    if document.title && document.title != "" && document.type && document.format && document.format != "" && document.path
      document.save
      @id = Document.last.id
      @localPath = "public/files/#{@id}#{@fileFormat}"
      document.update(path: "/files/#{@id}#{@fileFormat}")
      if !Dir.exist?(@directory)
        logger.info (File.join(@directory))
        Dir.mkdir(@directory)
        File.chmod(0777, @directory)
      end
      cp(file.path, @localPath)
      File.chmod(0777, @localPath)
      redirect '/'
    else
      redirect '/save_document'
    end 
  end

  get '/users' do
    erb :users
  end

  get '/login' do
    if(session[:user_id])
      redirect '/'
    else
      erb :login
    end
  end

  post '/login' do
    user = User.find(email: params['email'])
    if user && user.password == params['pwd']
      session[:user_id] = user.id
      session[:user_name] = user.name
      session[:user_role] = user.role
      logger.info(session[:user_role])
      @current_user = User.find(id: session[:user_id])
      redirect '/'
    else
      redirect '/login'
    end
  end

  get '/documents' do
    @documents = Document
    erb :documents
  end

  get '/doc_view/:id' do
    #@path = '/public/files/'.concat(params["document"].concat(params["format"]))
    @document = Document.find(id: params[:id])
    erb :doc_view 
  end

end

