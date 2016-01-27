require "#{File.expand_path(File.dirname(__FILE__))}/slack-rss-bot/rss.rb"
require 'slack/incoming/webhooks'
require 'dotenv'
Dotenv.load

module SlackRssBot
  def self.run
    slack = Slack::Incoming::Webhooks.new(ENV.fetch('SLACK_WEBHOOK_URL'), channel: '#api_test')

    # TODO: ファイルから読み込むなどする
    # とりあえずはてブホットエントリ
    url = 'http://feeds.feedburner.com/hatena/b/hotentry'
    icon_url = 'http://hatenacorp.jp/images/hatenaportal/company/resource/hatena-bookmark-logo-s.png'
    color = '#008fde'
    slack.username = feed_name = 'hatebu'
    slack.icon_emoji = ':ghost:'

    rss = SlackRssBot::RSS.new(feed_name, url)

    if rss.update?
      items = rss.feed.items
      items[0...rss.update_feed_count].each do |item|
        attachments = [{
          fallback: "#{item.title} - #{rss.feed.channel.title} #{item.link}",
          author_name: rss.feed.channel.title,
          author_icon: icon_url,
          title: item.title,
          title_link: item.link,
          text: item.description,
          color: color
        }]

        slack.post("", attachments: attachments)
      end
    end
  end
end
