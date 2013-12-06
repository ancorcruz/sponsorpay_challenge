require 'sinatra'
require 'haml'
require './lib/sponsor_pay/client'

set :haml, format: :html5
set :sponsorpay_api_key, "b07a12df7d52e6c118e5d47d3f9e60135b109a1f"

def client
  @client ||= SponsorPay::Client.new(settings.sponsorpay_api_key)
end

def request_params
  @request_params ||= {
    "appid"       => "157",
    "device_id"   => "2b6f0cc904d137be2 e1730235f5664094b 831186",
    "locale"      => "de",
    "ip"          => "109.235.143.113",
    "offer_types" => "112",
    "timestamp"   =>  Time.now.to_i.to_s,
  }
end

before do
  expires 600, :private, :must_revalidate
end

get '/' do
  haml :index
end

get '/offers' do
  sanitized_params = params.select { |key, value| ["uid", "pub0", "page"].include?(key) && value }
  begin
    @offers = client.fetch_offers request_params.merge(sanitized_params)
  rescue SponsorPay::InvalidSignature
    @offers = []
  end

  haml :offers
end
