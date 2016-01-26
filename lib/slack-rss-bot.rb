require "#{File.expand_path(File.dirname(__FILE__))}/slack-rss-bot/rss.rb"

module SlackRssBot
  def self.run
    # TODO: ファイルから読み込むなどする
    # とりあえずはてブホットエントリ
    url = 'http://feeds.feedburner.com/hatena/b/hotentry'
    rss = SlackRssBot::RSS.new(url)

    if rss.update?
      # TODO: Slackへ新しい記事を投稿
    end
  end
end
