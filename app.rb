require 'sinatra'

set :protection, except: [:json_csrf]

get '/' do
  erb :index
end

post '/login-form' do
  redirect to 'https://mock-sis.onrender.com/callback-form'
end

post '/login-redirect' do
  redirect to 'https://mock-sis.onrender.com/callback-redirect'
end

post '/login-meta' do
  redirect to 'https://mock-sis.onrender.com/callback-meta'
end
