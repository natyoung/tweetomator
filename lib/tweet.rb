require_relative './markov_chain'
require_relative './finders/emoji_finder'

class Tweet
  def initialize(max_length, markov_chain)
    @max_length = max_length
    @markov_chain = markov_chain
  end

  def compose(hashtags)
    text = @markov_chain.generate
    text = text.strip.capitalize
    text = insert_emoji(text, 5)
    insert_hashtags(text, hashtags)
  end

  private

  def insert_emoji(text, remaining_emojis)
    if (text.length < @max_length + " #{127872.chr('utf-8')}".length) && remaining_emojis > 0 && [true, false].sample
      return insert_emoji(append(text, EmojiFinder.new.find), remaining_emojis - 1)
    end
    text
  end

  def insert_hashtags(text, hashtags)
    out = text
    hashtags.each do |h|
      index = text.index(h)
      out = text.insert(index, '#') if index != nil && text.index("##{h}") == nil && text.length < @max_length + 1
    end

    hashtag = "##{hashtags.sample}"
    if out.length == text.length && text.length < @max_length + hashtag.length && [true, false].sample
      out = append(out, hashtag)
    end
    out
  end

  def append(text, append)
    text << ' ' << append
  end
end
