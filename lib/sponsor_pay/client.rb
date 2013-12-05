require 'json'
require 'open-uri'
require 'digest/sha1'

module SponsorPay
  class Client
    def initialize api_key
      @api_key = api_key
    end

    def fetch_offers params
      JSON.parse get_offers params
    end

    private

    def prepare_params raw_params
      normalized_params = {}.tap { |params| raw_params.each { |k, v| params[k] = v.gsub(/\s+/, "") } }
      sorted_params     = normalized_params.sort
      pairs_array       = sorted_params.inject([]) { |pairs, param| pairs << param.join("=") }
      params_str        = pairs_array.join "&"
      hashkey           = Digest::SHA1.hexdigest(params_str + "&#{@api_key}")

      params_str + "&hashkey=#{hashkey}"
    end

    def get_offers raw_params
      params = prepare_params raw_params
      open("http://api.sponsorpay.com/feed/v1/offers.json?#{params}").read
    end
  end
end
