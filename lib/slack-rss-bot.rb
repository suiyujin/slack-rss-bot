require "#{File.expand_path(File.dirname(__FILE__))}/slack-rss-bot/rss.rb"
require 'slack/incoming/webhooks'
require 'yaml'
require 'dotenv'
Dotenv.load

module SlackRssBot
  def self.run
    slack = Slack::Incoming::Webhooks.new(ENV.fetch('SLACK_WEBHOOK_URL'), channel: '#api_test')

    config = load_config
    config['feeds'].each do |feed|
      slack.username = feed_name = feed['name']
      slack.icon_emoji = ":#{feed['icon_emoji']}:"
      rss = SlackRssBot::RSS.new(feed_name, feed['url'])

      if rss.update?
        items = rss.feed.items
        items[0...rss.update_feed_count].each do |item|
          attachments = [{
            fallback: "#{item.title} - #{rss.feed.channel.title} #{item.link}",
            author_name: rss.feed.channel.title,
            author_icon: feed['icon_url'],
            title: item.title,
            title_link: item.link,
            text: item.description,
            color: feed['color']
          }]

          slack.post("", attachments: attachments)
        end
      end
    end
  end

  def self.load_config
    YAML.load_file("#{File.expand_path(File.dirname(__FILE__)).sub(/lib/, 'config')}/config.yml")
  end
end
