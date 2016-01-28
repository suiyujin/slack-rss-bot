require 'rss'
require 'redis'

module SlackRssBot
  class RSS
    include ::RSS

    attr_reader :feed

    def initialize(feed_name, url)
      @feed_name = feed_name
      @feed = parse(url)

      @redis = Redis.new
    end

    def update?
      (@feed.items.first.title != last_update_title) || last_update_title.nil?
    end

    def update_feed_count
      items = @feed.items
      update_feed_count = items.index do |item|
        item.title == last_update_title
      end
      @redis.set(@feed_name, @feed.items.first.title)

      return items.size if update_feed_count.nil?
      update_feed_count
    end

    private

    def parse(url)
      self.class::Parser.parse(url)
    rescue RSS::InvalidRSSError
      self.class::Parser.parse(url, false)
    end

    def last_update_title
      @redis.get(@feed_name)
    end
  end
end
