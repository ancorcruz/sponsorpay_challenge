require 'json'
require 'open-uri'
require 'digest/sha1'

module SponsorPay
  class InvalidSignature < Exception; end

  class Client
    def initialize api_key
      @api_key = api_key
    end

    def fetch_offers params
      JSON.parse(get_offers params)["offers"]
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
      params   = prepare_params raw_params
      response = open "http://api.sponsorpay.com/feed/v1/offers.json?#{params}"
      raise InvalidSignature unless valid_response? response
      response.read
    end

    def valid_response? response
      response_signature  = response.meta["x-sponsorpay-response-signature"]
      generated_signature = Digest::SHA1.hexdigest(response.read + @api_key)

      response_signature == generated_signature
    end
  end
end
