require 'bundler'
require 'thin'
require 'open-uri'
require 'rss'
Bundler.require
Bundler.require :development if development?
require 'newrelic_rpm'

class App < Sinatra::Base

  helpmsg = "You can say things like, Alexa tell srvbc messages to "
  helpmsg += "list all messages, or alexa tell srvbc messages to "
  helpmsg += "play Adel Akls latest message"

  get '/health' do
    json 'ok'
  end

  post '/' do
    redis = Redis.new(:host => ENV['REDIS_HOST'], :port => 6380, :db => 15)
    # valid Alexa request?
    query_json = JSON.parse(request.body.read.to_s)
    # create a 'query' object from the request
    query = AlexaRubykit.build_request(query_json)

    # capture session info
    session = query.session

    # reply object
    reply = AlexaRubykit::Response.new

    if (query.type == 'LAUNCH_REQUEST')
      reply.add_speech('Hello!')
    end

    if (query.type == 'INTENT_REQUEST')
      puts query.name
      srvbcurl = "http://www.srvbc.org/podcast.asp"
      message = {}
      outtext = ""
      case query.name
      when "MessageIntent"
        p query.slots
        feed = get_rss(srvbcurl)
        speaker = nil
        if query.slots['speaker'].key?('value') && !query.slots['speaker']['value'].nil? then
          # user asked for a specific speaker or message
          speaker = query.slots['speaker']['value']
          speaker.gsub!(/[sS]$/,'')
        end
        message = find_message(feed,speaker)
        outtext = "Playing #{message[:title]}, a #{message[:description]}" unless message.nil?
        p outtext
        if outtext != "" then
          message[:url].gsub!('http','https')
          message[:url].gsub!('httpss','https')
          puts "sending stream url #{message[:url]}"
          reply.add_audio_url(message[:url])
          reply.add_speech(outtext)
        else
          reply.add_speech("Message with title or speaker #{speaker} not found")
        end
        reply.add_hash_card( { :title => 'SRVBC Messages', :subtitle => "Intent #{query.name}" } )
      
      when "ListIntent"
        outtext = "The first 5 messages are: "
        count = 0
        feed = get_rss(srvbcurl)
        
        feed.items.each do |item|
          count += 1
          outtext += item.title + ", "
          break if count >= 5
        end
        reply.add_speech(outtext)
        reply.add_hash_card( { :title => 'SRVBC Messages', :subtitle => "Intent #{query.name}" } )
        # get a list of the most recent 5 messages
      when "HelpIntent"
        reply.add_speech(helpmsg)
        reply.add_hash_card( { :title => 'SRVBC Messages', :subtitle => "Help" } )
      else
        reply.add_speech(helpmsg)
        reply.add_hash_card( { :title => 'SRVBC Messages', :subtitle => "Help" } )
      end

      # here is a 'Standard' card, which includes an image:
      # reply.add_hash_card( { :type => "Standard", :title => "Alexa Skill", :subtitle => "Intent #{query.name}", :image => { :small => "small_url", :large => "large_url" } } )
    end

    if (query.type =='SESSION_ENDED_REQUEST')
      # Wrap up sessions etc
      p "#{query.type}"
      p "#{query.reason}"
      halt 200
    end

    # Return response
    content_type 'application/json'
    reply.build_response
  end

  not_found do
    json "Invalid endpoint."
  end
end

def refresh_cache(redis,rss)
  
end

def get_rss(url)
  rss = open(url)
  feed = RSS::Parser.parse(rss,false)
  feed.items
end

def find_message(items,speaker)
  message = {}
  if speaker.nil? then
    message[:title] = items.first.title
    message[:description] = items.first.description
    message[:url] = items.first.enclosure.url
  else
    items.each do |item|
      if item.description.downcase.include?(speaker.downcase) || item.title.downcase.include?(speaker.downcase)
        message[:title] = item.title
        message[:description] = item.description
        message[:url] = item.enclosure.url
        break 
      end
    end
  end
  message
end