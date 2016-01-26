require 'rss'

module SlackRssBot
  class RSS
    include ::RSS

    attr_reader :feed

    def initialize(url)
      @feed = parse(url)
    end

    def update?
      update_time > last_update_time
    end

    private

    def parse(url)
      self.class::Parser.parse(url)
    rescue RSS::InvalidRSSError
      self.class::Parser.parse(url, false)
    end

    def update_time
      update_time = @feed.items.first.dc_date
      update_time.nil? ? @feed.items.first.pubDate : update_time
    end

    def last_update_time
      # TODO: 前回の更新時間を返す
      Time.local(2016,1,20)
    end
  end
end
