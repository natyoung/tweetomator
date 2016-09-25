require 'twitter'
require 'pragmatic_segmenter'
require 'stopwords'
require_relative 'tweet'
require_relative 'finders/flickr_findr'
require_relative 'finders/emoji_finder'
require_relative 'clients/flickr_client'
require_relative 'clients/twitter_client'

class Tweetomator
  module Fixed
    MaxLength = 140
    freeze
  end

  def initialize
    @twitter_client = TwitterClient.new(ENV['TWITTER_CONSUMER_KEY'],
                                        ENV['TWITTER_CONSUMER_SECRET'],
                                        ENV['TWITTER_ACCESS_TOKEN'],
                                        ENV['TWITTER_ACCESS_TOKEN_SECRET'],
                                        ENV['TWITTER_USERNAME'])

    @flickr_client = FlickrClient.new(ENV['FLICKR_API_KEY'],
                                      ENV['FLICKR_SHARED_SECRET'])

    @segmenter = PragmaticSegmenter::Segmenter.new(text: File.read('../text/input.txt'))
    @sentences = @segmenter.segment
    @markov_chain = MarkovChain.new(Fixed::MaxLength, @sentences)
    stopped = @markov_chain.words.reject { |w| Stopwords.is?(w) }.map { |word| word[0].to_s.strip.downcase }
    counted = stopped.reduce(Hash.new(0)) { |h, w| h[w] += 1; h }
    @hashtags = counted.sort_by{ |_, count| count }.last(10).map { |s| s[0] }.reject { |w| /.*\W+.*/.match(w) != nil }
  end

  def run_once
    r = (1..9).to_a.sample
    if r < 4
      tweet_with_image!
    elsif r < 7
      tweet!
    else
      follow!
    end
  end

  private

  def tweet!
    tweet = Tweet.new(Fixed::MaxLength, @markov_chain).compose(@hashtags)
    @twitter_client.update(tweet)
  end

  def tweet_with_image!
    tweet = Tweet.new(Fixed::MaxLength, @markov_chain).compose(@hashtags)
    image = FlickrFindr.new(@flickr_client).download_image(@hashtags.sample)

    if image.length > 0 && File.exists?(image)
      @twitter_client.update_with_media(tweet, File.new(image))
      File.delete(image)
    end
  end

  def follow!
    user = @twitter_client.random_follower_of_follower
    @twitter_client.follow(user) if user
  end

  def retweet!
    tweet = @twitter_client.search("#{@hashtags.sample}")
    @twitter_client.retweet(tweet.id)
  end
end
