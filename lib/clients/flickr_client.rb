require 'flickraw'

class FlickrClient
  def initialize(api_key, shared_secret)
    FlickRaw.api_key = api_key
    FlickRaw.shared_secret = shared_secret
  end

  def uri(uri)
    FlickRaw.url(uri)
  end

  def search(query)
    flickr.photos.search(tags: query, min_upload_date: 1357028420, safe_search: 1)
  end
end
