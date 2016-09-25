class MarkovChain
  attr_accessor :words

  def initialize(max_length, sentences)
    @max_length = max_length
    @words = {}
    @sentence_beginnings = sentences.flat_map { |s| s.strip.scan(/^\S+/i) }
    build_chain(sentences.flat_map { |s| s.split(' ') })
  end

  def generate
    text = ''
    word = @sentence_beginnings.sample
    until text.count('.') == 1 || text.length + word.length + 1 >= @max_length
      text = "#{text}#{word} "
      word = get(word)
    end
    text.capitalize
  end

  private

  def build_chain(words)
    words.each_with_index do |word, i|
      add(word, words[i + 1]) unless i >= (words.size - 2)
    end
  end

  def add(word, next_word)
    @words[word] = Hash.new(0) if @words[word] == nil
    @words[word][next_word] += 1
  end

  def get(word)
    return '' if @words[word] == nil
    sum = @words[word].reduce(0) { |sum, kv| sum += kv[1] }
    random = rand(sum) + 1
    count = 0

    @words[word].find do |w, i|
      count += i
      count >= random
    end.first
  end
end
