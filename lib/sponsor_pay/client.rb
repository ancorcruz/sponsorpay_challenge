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
      params        = prepare_params raw_params
      response      = open "http://api.sponsorpay.com/feed/v1/offers.json?#{params}"
      response_body = response.read
      raise InvalidSignature unless valid_response? response.meta, response_body
      response_body
    end

    def valid_response? headers, body
      headers["x-sponsorpay-response-signature"] == Digest::SHA1.hexdigest(body + @api_key)
    end
  end
end
