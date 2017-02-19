require "bundler"
require 'thin'
require 'open-uri'
Bundler.require
Bundler.require :development if development?

helpmsg = "You can say things like, Alexa tell s. r. v. b. c. messages to "
helpmsg += "list all messages, or alexa tell s. r. v. b. c. messages to "
helpmsg += "play Adel Akls latest message"

get '/health' do
  json "ok"
end

post '/' do

  # valid Alexa request?
  query_json = JSON.parse(request.body.read.to_s)
  # create a 'query' object from the request
  query = AlexaRubykit.build_request(query_json)

  # capture session info
  session = query.session
  p session.new?
  p session.has_attributes?
  p session.session_id
  p session.user_defined?

  # reply object
  reply = AlexaRubykit::Response.new

  if (query.type == 'LAUNCH_REQUEST')
    # load session into DB etc
    reply.add_speech('Hello!')
  end

  if (query.type == 'INTENT_REQUEST')

    p "#{query.slots}"
    p "#{query.name}"

    case query.name
    when "MessageIntent"
      # Send an audio stream response
    when "ListIntent"
      srvbcurl = "http://www.srvbc.org/podcast.asp"
      rss = SimpleRSS.parse open(srvbcurl)
      puts "Title: #{rss.channel.title}"
      outtext = "I found the following messages: "
      count = 0
      rss.items.each do |item|
        count += 1
        outtext += item.title + ", "
        break if count > 5
      end
      reply.add_speech(outtext)
      # the card response (for the Alexa app)
      reply.add_hash_card( { :title => 'SRVBC Messages', :subtitle => "Intent #{query.name}" } )
      # get a list of the most recent 5 messages
    when "HelpIntent"
      puts "help message"
      reply.add_speech(helpmsg)
      reply.add_hash_card( { :title => 'SRVBC Messages', :subtitle => "Help" } )
    else
      reply.add_speech(helpmsg)
      # the card response (for the Alexa app)
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
