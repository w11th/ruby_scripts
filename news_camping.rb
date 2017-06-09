#!/usr/bin/env ruby -w

require 'camping'
require 'uri'
require 'feed-normalizer'
require 'open-uri'

Camping.goes :News

module News::Controllers
  class Index < R '/'
    def get
      render :frontpage
    end
  end
end

module News::Views
  @@search_term = 'ruby on rails'
  def frontpage
    meta charset: 'utf-8'
    h1 "News about #{@@search_term.capitalize}"
    ul do
      url = "https://news.google.com/news?cf=all&hl=zh-CN&pz=1&ned=cn&output=rss&q=#{URI.encode @@search_term}"
      feed = FeedNormalizer::FeedNormalizer.parse open(url)

      feed.items.each do |item|
        div do
          a href: item.url do
            item.title
          end
        end
      end
    end
  end
end
