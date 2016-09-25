class TwitterClient
  def initialize(consumer_key, consumer_secret, access_token, access_token_secret, username)
    @rest_client = Twitter::REST::Client.new do |config|
      config.consumer_key = consumer_key
      config.consumer_secret = consumer_secret
      config.access_token = access_token
      config.access_token_secret = access_token_secret
    end
    @username = username
  end

  def random_follower_of_follower
    follower = @rest_client.followers.attrs[:users].sample[:screen_name]
    @rest_client.friend_ids(follower).attrs[:ids].sample if follower
  end

  def update_with_media(text, image_file)
    @rest_client.update_with_media(text, image_file)
  end

  def update(text)
    @rest_client.update(text)
  end

  def search(query)
    @rest_client.search("#{query} -rt -from:#{@username}", { lang: 'en' }).first
  end

  def retweet(tweet_id)
    @rest_client.retweet(tweet_id)
  end

  def follow(user)
    @rest_client.follow(user)
  end
end
