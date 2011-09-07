#!/usr/lib/env ruby
# encodung: utf-8

require 'mechanize'

def generate_hash(string)
  Digest::SHA1.hexdigest(string)
end

def scrape_events
  date_now = Time.now.strftime('%d.%m.%Y')
  
  agent = Mechanize.new
  page = agent.get('https://kbu.freifunk.net/index.php/Hauptseite')
  
  upcomming_meetings = []
  
  page.search('//*[@id="regelmaessig"]/ul/li').each do |treffen|
    meeting = {}
    meeting[:date] = /(\d\d).(\d\d).(\d\d\d\d)/.match(treffen.text).to_s
    meeting[:time] = /(\d\d|\d\d:\d\d)\sUhr/.match(treffen.text).to_s
    meeting[:location] = /im.*(um|ab)/.match(treffen.text).to_s.gsub(/um|ab/, "").gsub(/im/, "").gsub(/^\s/, "").gsub(/\s$/, "")
    meeting[:hash] = generate_hash(treffen.text)
    upcomming_meetings << meeting
  end

  upcomming_meetings
end

def event_already_transmitted?(string)
   already_transmitted = false

   File.new('/home/dm/projects/ffinvity/already_sent_events', 'r').each_line do |line|
    line = line.chomp # removed tailing line separator
    
    if line.eql?(string)
      already_transmitted = true
    end
  end
  already_transmitted
end

scrape_events.each do |event|
  p event
  puts event_already_transmitted?(event[:hash].to_s)
end
