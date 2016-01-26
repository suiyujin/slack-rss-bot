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
    rss = SlackRssBot::RSS.new(url)

    if rss.update?
      slack.username = 'hatebu'
      slack.icon_emoji = ':ghost:'

      # TODO: 新しい記事を投稿
      item = rss.feed.items.first
      thumb_url = item.content_encoded.match(/img src=\"(http:\/\/cdn-ak.b.st-hatena.com\/entryimage\/\d+-\d+\.\w+)\"/)[1]
      attachments = [{
        fallback: "#{item.title} - #{rss.feed.channel.title} #{item.link}",
        author_name: rss.feed.channel.title,
        title: item.title,
        title_link: item.link,
        text: item.description,
        color: "#008fde",
        author_icon: "http://hatenacorp.jp/images/hatenaportal/company/resource/hatena-bookmark-logo-s.png",
        thumb_url: thumb_url
      }]

      slack.post("", attachments: attachments)
    end
  end
end
