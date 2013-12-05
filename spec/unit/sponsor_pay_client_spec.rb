require 'spec_helper'
require 'sponsor_pay/client'

module SponsorPay
  describe Client do
    let(:api_key) { "e95a21621a1865bcbae3bee89c4d4f84" }

    describe "#fetch_offers" do
      it "receives an OK response" do
        client = Client.new api_key
        params = {}
        offers = client.fetch_offers params
        offers["code"].should be_eql "OK"
      end
    end
  end
end
