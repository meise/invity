#!/usr/lib/env ruby
# encoding: utf-8
=begin
Copyright Daniel Meißner <dm@3st.be>, 2011

This file is part of Invity to send email notifications to upcoming Freifunk events.

This script is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This Script is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Invity. If not, see <http://www.gnu.org/licenses/>.
=end

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
    
    meeting[:links] = []
    treffen.search("./a/@href").each do |link|
      meeting[:links] << link.to_s
    end

    upcomming_meetings << meeting
  end

  upcomming_meetings
end

def event_already_transmitted?(string)
   # this fuction is to verify, that a notification for a event is not send already
   # fuction returns true if a event notification is already send

   already_transmitted = false
   # TODO: Handle exeption if file not exists
   # TODO: Fix static path
   File.new('/home/invity/ffinvity/already_sent_events', 'r').each_line do |line|
    line = line.chomp # removed tailing line separator
    
    if line.eql?(string)
      already_transmitted = true
    end
  end

  already_transmitted
end

def write_event_hash(hash)
  # writes a event hash into a file
  # TODO: Remove duplicated static path
  File.open('/home/invity/ffinvity/already_sent_events', 'a') do |file|
    file << "#{hash}\n"
  end
end

def check_difference(date)
  # returns the difference between now and the upcomming event
  (date.to_date - Time.now.strftime('%d.%m.%Y').to_date).to_i
end

def send_email(event)
  email = {}
  email[:server]      = 'localhost'
  email[:from]        = 'invity@kbu.freifunk.net'
  email[:from_alias]  = 'Invity - Invitation Bot'
  email[:subject]     = "Nächstes Treffen: #{event[:date]}"
  email[:to]          = 'dm@3st.be'

  link_index, link_with_index = '', ''
  event[:links].each_with_index{  |link,index| link_index += "[#{index+1}]"; link_with_index += "[#{index+1}] #{link}\n" }

  email[:msg] = <<END_OF_MESSAGE
From: #{email[:from_alias]} <#{email[:from]}>
To: <#{email[:to]}>
Subject: #{email[:subject]}

Einladung
#########

Das nächste Freifunk Köln, Bonn und Umgebung Treffen findet statt

am #{event[:date]}
um #{event[:time]}
im #{event[:location]} #{link_index}

#{link_with_index}
Um zahlreiches erscheinen wird gebeten :)
END_OF_MESSAGE

  Net::SMTP.start(email[:server]) do |smtp|
    smtp.send_message email[:msg], email[:from], email[:to]
  end
end

scrape_events.each do |event|
  if not event_already_transmitted?(event[:hash].to_s)
    if (difference = check_difference(event[:date])) <= 3 and difference > 0

      # TODO: Add debugging information 
      if send_email(event)
        write_event_hash(event[:hash])      
      end
    end
  end

  true
end
