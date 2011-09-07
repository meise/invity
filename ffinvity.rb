#!/usr/lib/env ruby
# encoding: utf-8

require 'mechanize'
require 'active_support/core_ext'
require 'net/smtp'
require 'rainbow'

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

    meeting[:date] = /(\d\d).(\d\d).(\d\d\d\d)/.match(treffen.text).to_s # grep date with pattern
    meeting[:time] = /(\d\d|\d\d:\d\d)\sUhr/.match(treffen.text).to_s # grep time with pattern TODO: that should be fixed with a better general purpose pattern
    meeting[:location] = /im.*(um|ab)/.match(treffen.text).to_s.gsub(/um|ab/, "").gsub(/im/, "").gsub(/^\s/, "").gsub(/\s$/, "") # grep location with pattern TODO: that should be fixed with a better general purpose pattern
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

def write_event_hash(hash)
  File.open('/home/dm/projects/ffinvity/already_sent_events', 'a') do |file|
    file << "#{hash}\n"
  end
end

def check_difference(date)
  (date.to_date - Time.now.strftime('%d.%m.%Y').to_date).to_i
end

def send_email(event)
  email = {}
  email[:server]      = 'localhost'
  email[:from]        = 'invity@kbu.freifunk.net'
  email[:from_alias]  = 'Invity - Invitation Bot'
  email[:subject]     = "Nächstes FF-KBU Treffen: #{event[:date]}"
  email[:to]          = 'dm@3st.be'

  email[:msg] = <<END_OF_MESSAGE
From: #{email[:from_alias]} <#{email[:from]}>
To: <#{email[:to]}>
Subject: #{email[:subject]}

Einladung
#########

Das nächste Freifunk Köln, Bonn und Umgebung Treffen findet statt am

#{event[:date]}
um
#{event[:time]}
im
#{event[:location]}

Auf zahlreiches erscheinen wird gebeten :)
END_OF_MESSAGE

  Net::SMTP.start(email[:server]) do |smtp|
    smtp.send_message email[:msg], email[:from], email[:to]
  end
end

scrape_events.each do |event|
  
  if not event_already_transmitted?(event[:hash].to_s)
    if (difference = check_difference(event[:date])) <= 2 and difference > 0
      p event
      puts "difference".color(:yellow)
      if send_email(event)
        puts "E-Mail send successfull".color(:green)
        write_event_hash(event[:hash])      
      end
    end
  end
  true
end
