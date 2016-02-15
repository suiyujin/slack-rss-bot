require 'rss'
require 'redis'

module SlackRssBot
  class RSS
    include ::RSS

    attr_reader :feed, :before_links

    def initialize(feed_name, url)
      @feed_name = feed_name
      @feed = parse(url)
      @redis = Redis.new
    end

    def update?(links)
      @before_links = @redis.smembers(@feed_name)
      (links - before_links).size > 0
    end

    def save_last_links(links)
      @redis.del(@feed_name)
      links.each { |title| @redis.sadd(@feed_name, title) }
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
