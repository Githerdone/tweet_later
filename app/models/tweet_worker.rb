class TweetWorker
  include Sidekiq::Worker

  def perform(tweet_id)
    tweet = Tweet.find(tweet_id)
    user  = tweet.user

    # uri = URI.parse
    t_user = Twitter::Client.new(oauth_token: user.oauth_token, oauth_token_secret: user.oauth_secret)
    t_user.update(tweet.status)
  end
end
