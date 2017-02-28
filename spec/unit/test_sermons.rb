ENV['RACK_ENV'] = 'test'

require './app'
require 'test/unit'
require 'rack/test'
require 'rspec'
Bundler.require
Bundler.require :development if development?

class SermonTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    SRVBCApp
  end

  def test_health_check
    get '/health'
    assert last_response.ok?
    assert_equal '"ok"', last_response.body
  end

  def test_it_lists_messages
    #allow(app).to_receive(:get_messages).and_return(File.read('fixtures/MessageList.json'))
    request_body = File.read('fixtures/ListRequest.json')
    post '/', request_body
    js_body = JSON.parse(last_response.body)
    #p js_body['response']['outputSpeech']['text']
    assert js_body['response']['outputSpeech']['type'].include?('PlainText')
    assert js_body['response']['outputSpeech']['text'].include?(',')
    assert js_body['response']['card']['subtitle'].include?('Intent ListIntent')
  end

  def test_it_gets_newest_message
    #app.stub(:get_messages).and_return(File.read('fixtures/MessageList.json'))
    request_body = File.read('fixtures/NewestMessageRequest.json')
    post '/', request_body
    js_body = JSON.parse(last_response.body)
    #p js_body['response']
    assert js_body['response']['outputSpeech']['type'].include?('PlainText')
    assert js_body['response']['outputSpeech']['text'].include?('Playing')
    assert js_body['response']['outputSpeech']['text'].include?('Sermon by')
    assert js_body['response']['directives'][0]['playBehavior'].include?('REPLACE_ALL')
    assert js_body['response']['directives'][0]['audioItem']['stream']['url'].include?('https')
  end
  
  def test_it_gets_a_specific_message
    #app.stub(:get_messages).and_return(File.read('fixtures/MessageList.json'))
    request_body = File.read('fixtures/SpecificMessageRequest.json')
    post '/', request_body
    js_body = JSON.parse(last_response.body)
    #p js_body['response']
    assert js_body['response']['outputSpeech']['type'].include?('PlainText')
    assert js_body['response']['outputSpeech']['text'].include?('Playing')
    assert js_body['response']['outputSpeech']['text'].include?('Sermon by Randy')
    assert js_body['response']['directives'][0]['playBehavior'].include?('REPLACE_ALL')
    assert js_body['response']['directives'][0]['audioItem']['stream']['url'].include?('https')
  end
end