require 'rss'
require 'redis'

module SlackRssBot
  class RSS
    include ::RSS

    attr_reader :feed, :before_titles

    def initialize(feed_name, url)
      @feed_name = feed_name
      @feed = parse(url)

      @redis = Redis.new
    end

    def update?(titles)
      @before_titles = @redis.smembers(@feed_name)
      (titles - before_titles).size > 0
    end

    def save_last_titles(titles)
      @redis.del(@feed_name)

      titles.each do |title|
        @redis.sadd(@feed_name, title)
      end
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
