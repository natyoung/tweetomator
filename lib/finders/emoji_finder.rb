class EmojiFinder
  def find
    [(127744..127775),
     (127792..127855),
     (127872..127887),
     (127904..127935),
     (128000..128239)].map { |r| Array(r) }.inject(:+).sample.chr('utf-8')
  end
end
