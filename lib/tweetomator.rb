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

    @segmenter = PragmaticSegmenter::Segmenter.new(text: File.read(ENV['MARKOV_CHAIN_INPUT_TEXT_FILE']))
    @sentences = @segmenter.segment
    @markov_chain = MarkovChain.new(Fixed::MaxLength, @sentences)
    @hashtags = @markov_chain.words
                    .map { |word| word[0].to_s.strip.downcase.gsub(/\W+/, '') }
                    .reject { |w| Stopwords.is?(w) || w.empty? }
                    .reduce(Hash.new(0)) { |h, w| h[w] += 1; h }
                    .sort_by{ |_, count| count }
                    .last(10).reverse
                    .map { |s| s[0] }
  end

  def run_once
    r = (1..9).to_a.sample
    if r < 3
      tweet!
    elsif r < 6
      tweet_with_image!
    elsif r < 7
      follow!
    elsif r < 8
      retweet!
    else
      favorite!
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
    @twitter_client.follow
  end

  def retweet!
    @twitter_client.retweet(@hashtags.sample)
  end

  def favorite!
    @twitter_client.favorite(@hashtags.sample)
  end
end
