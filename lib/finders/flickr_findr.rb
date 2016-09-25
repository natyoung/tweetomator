require 'open-uri'

class FlickrFindr
  def initialize(flickr_client)
    @flickr_client = flickr_client
  end

  def download_image(query)
    results = @flickr_client.search(query)
    uri = @flickr_client.uri(results.to_a.sample)
    download(uri, 'image')
  end

  private

  def download(uri, local_path)
    File.open(local_path, 'wb') do |saved_file|
      open(uri, 'rb') do |read_file|
        saved_file.write(read_file.read)
      end
    end
    local_path
  end
end
