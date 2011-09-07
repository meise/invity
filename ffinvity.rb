#!/usr/lib/env ruby
# encodung: utf-8


require 'mechanize'

agent = Mechanize.new

page = agent.get('https://kbu.freifunk.net/index.php/Hauptseite')

page.search('//*[@id="regelmaessig"]/ul/li').each do |treffen|
  puts treffen.text
end
