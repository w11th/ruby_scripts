require 'camping'
require 'feed-normalizer'

require 'uri'
require 'shorturl'

Camping.goes :ShortBlogs

module ShortBlogs
  module Controllers
    class Frontpage < R '/'
      def get
        render :frontpage
      end
    end
  end

  module Views
    @@search_term = 'ruby on rails'
    @@number_of_results = 15

    def frontpage
      h1 "Blogs about #{@@search_term}"

      url = 'https://news.google.com/news?'
      url << "hl=en&q=#{URI.encode(@@search_term)}&ie=utf-8"
      url << "&num=#{@@number_of_results}&output=rss&scoring=d"

      feed = FeedNormalizer::FeedNormalizer.parse open(url)

      return unless feed

      feed.items.each do |item|
        url = ShortURL.shorten(item.url)
        div do
          a(href: url) { "#{item.title} - #{url}" }
        end
      end
    end
  end
end
