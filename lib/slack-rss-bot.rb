require "#{File.expand_path(File.dirname(__FILE__))}/slack-rss-bot/rss.rb"
require 'slack/incoming/webhooks'
require 'yaml'
require 'logger'
require 'dotenv'
Dotenv.load

module SlackRssBot
  def self.run
    logger = Logger.new("#{File.expand_path(File.dirname(__FILE__)).sub(/lib/, 'log')}/slack-rss-bot.log")
    slack = Slack::Incoming::Webhooks.new(ENV.fetch('SLACK_WEBHOOK_URL'), channel: '#api_test')

    config = load_config
    config['feeds'].each do |feed|
      slack.username = feed_name = feed['name']
      slack.icon_emoji = ":#{feed['icon_emoji']}:"

      rss = SlackRssBot::RSS.new(feed_name, feed['url'])
      links = rss.feed.items.map(&:link)

      if rss.update?(links)
        rss.save_last_links(links)

        new_items = rss.feed.items.select do |item|
          !rss.before_links.include?(item.link)
        end
        logger.debug("new_titles: #{new_items.map(&:title)}")

        new_items.each do |new_item|
          attachments = [{
            fallback: "#{new_item.title} - #{rss.feed.channel.title} #{new_item.link}",
            author_name: rss.feed.channel.title,
            # author_icon: feed['icon_filename'],
            title: new_item.title,
            title_link: new_item.link,
            text: new_item.description,
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
