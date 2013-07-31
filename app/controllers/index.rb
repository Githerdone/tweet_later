get '/' do
  erb :index
end

get '/sign_in' do
  # the `request_token` method is defined in `app/helpers/oauth.rb`
  redirect request_token.authorize_url
end

get '/sign_out' do
  session.clear
  redirect '/'
end

get '/auth' do
  # the `request_token` method is defined in `app/helpers/oauth.rb`

  @access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
  p "&" * 80
  p @access_token
  # our request token is only valid until we use it to get an access token, so let's delete it from our session
  session.delete(:request_token)
  client = Twitter::Client.new(
    oauth_token: @access_token.token,
    oauth_token_secret: @access_token.secret
  )
  p client.methods
  # at this point in the code is where you'll need to create your user account and store the access token
  user = User.where(username: client.current_user.screen_name).first_or_create do |user|
    user.oauth_token = @access_token.token
    user.oauth_secret = @access_token.secret 
  end
  session[:id] = user.id
  erb :index
  
end

post '/tweet' do
  user = User.find(session[:id])
  @job_id = user.tweet(params[:tweet])
end

get '/status/:job_id' do
  job_is_complete(params[:job_id]).to_json
end

# this command runs the siqekiq server
# $ bundle exec sidekiq -r./config/environment.rb

# user posts a tweet
# there will be an ajax call every 10 seconds to '/status/:job_id'
# when the server response is true we'll display a pop with your tweet was sent
