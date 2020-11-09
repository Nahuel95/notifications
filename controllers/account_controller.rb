require 'json'
require './services/account_service.rb'
require 'sinatra/base'
require './exceptions/validation_model_error.rb'

class Account_controller < Sinatra::Base
    
  configure :development, :production do
    set :views, settings.root + '/../views'
  end

  before do
    @current_user = User.find_user_id(session[:user_id])
  end    

  post '/signUp' do
    
    name = params[:name]
    lastname = params[:lastname]
    dni = params[:dni]
    email = params[:email]
    pwd = params[:pwd]
    begin
      Account_service.sign_up(name, lastname, dni, email, pwd)
      redirect '/login'
    rescue Validation_model_error => e
      return erb :signUp
    end
    
  end
   
   get '/signUp' do
     erb :signUp
   end
  
   get '/log_out' do
    session.clear if @current_user
    redirect '/'
  end

  get '/login' do
    if @current_user
      redirect '/'
    else
      erb :login
    end
  end

  post '/login' do
    user = User.find_user_email(params['email'])
    if user && User_service.correct_password(user, params['pwd'])
      session[:user_id] = user.id
      redirect '/'
    else
      redirect '/login'
    end
  end
end 