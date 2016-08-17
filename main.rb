
require 'bundler/setup'

require 'dotenv'
Dotenv.load

require 'configatron'
require_relative 'config.rb'

require 'discordrb'
$bot = Discordrb::Commands::CommandBot.new token: ENV['TOKEN'], type: :user, prefix: configatron.prefix, advanced_functionality: false, debug: true #, log_mode: :debug

$bot.command(:megasoak, description: 'Displays info about balance etc.') do |event|
  get_balance
  percentage = $balance.to_f/configatron.treshold.to_f*100.0
  event.respond "The Bot is currently at #{percentage}% before it might soak (with a chance of ~10%)"
  $balance = nil
end

$bot.ready do
  def gen(number)
    charset = Array('A'..'Z') + Array('a'..'z')
    Array.new(number) { charset.sample }.join.to_sym
  end

  def get_balance
    $bot.user(configatron.tip_bot_id).pm '!balance'
    $bot.user(configatron.tip_bot_id).await(gen(20)) do |e|
      $balance = e.content[/(\d+[,.]\d+)/]
    end
    while $balance.nil?
      sleep(0.1)
    end
    $balance = $balance.to_i
  end


  get_balance
  while $balance.nil?
    sleep(0.1)
  end
  $bot.user(configatron.admin_id).pm "My balance is: #{$balance}"

  while 1 > 0
    get_balance

    if $balance > configatron.treshold
      num = rand(0.1..100)
      puts num
      if num <= 10
        $bot.channel(configatron.main_channel_id).send_message "Watch out! Your houses are gonna get flooded in a sec! Only real shibes stay and watch out!"
        sleep(1)
        $bot.channel(configatron.main_channel_id).send_message "!soak #{$balance}"
      end
    end
    $balance = nil
    # Sleep 5 minutes
    sleep(300)
  end
end

$bot.run
