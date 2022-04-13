require 'sinatra'
require 'sinatra/base'
require 'json'
require './classes/reddit_cast.rb'
require './classes/show.rb'

class RCServer < Sinatra::Base

  set :port, 8008
  use Rack::Session::Pool

  get '/' do
    haml :index, locals: locals
  end

  get "/now_showing" do
    content_type :json
    locals.to_json
  end

  get "/nextshow" do
    next_show

    content_type :json
    locals.to_json
  end

  get "/prevshow" do
    prev_show

    content_type :json
    locals.to_json
  end

  get "/nextchannel" do
    rcast.channel_up

    content_type :json
    locals.to_json
  end

  get "/prevchannel" do
    rcast.channel_down

    content_type :json
    locals.to_json
  end

  def locals
    { 
      channel_name: channel_name, 
      channel_number: channel_number, 
      show_id: show.youtube_id,
      show_name: show.short_title
    }
  end

  def next_show
    rcast.channel.next_show
  end

  def prev_show
    rcast.channel.prev_show
  end

  def channel_name
    rcast.channel.name
  end

  def channel_number
    prefix = rcast.listing_number < 9 ? "0" : ""
    "#{prefix}#{rcast.listing_number + 1}"
  end

  def show
    rcast.channel.now_showing
  end

  def rcast
    session[:reddit_cast]
    session[:reddit_cast] ||= RedditCast.new
  end
end

RCServer.run!