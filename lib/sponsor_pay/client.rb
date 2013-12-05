module SponsorPay
  class Client
    def initialize api_key
      @api_key = api_key
    end

    def fetch_offers params
      { "code" => "OK" }
    end
  end
end
