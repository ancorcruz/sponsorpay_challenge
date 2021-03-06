require 'spec_helper'
require 'sponsor_pay/client'

module SponsorPay
  describe Client do
    let(:api_key)    { "e95a21621a1865bcbae3bee89c4d4f84" }
    let(:client)     { Client.new api_key }
    let(:raw_params) {
      {
        appid:     "157",
        uid:        "player1",
        ip:         "212.45.111.17",
        locale:     "de",
        device_id:  "2b6f0cc904d137be2 e1730235f5664094b 831186",
        ps_time:    "1312211903",
        pub0:       "campaign2",
        page:       "2",
        timestamp:  "1312553361",
      }
    }

    describe "#fetch_offers" do
      let(:sample_json) { File.read 'spec/assets/sp_response.json' }

      it "returns fetched offers" do
        client.should_receive(:get_offers).with(raw_params).and_return sample_json
        offers = client.fetch_offers raw_params
        offers.should have(1).offer
      end

      it "checks response signature" do
        response = double(:meta => { "x-sponsorpay-response-signature" => "3a3f93a35145ab7b18539910a8537d2286d8d155" },
                          :read => sample_json)
        client.stub(:open).and_return response
        client.should_receive(:valid_response?).with(response.meta, response.read).and_return true

        client.fetch_offers raw_params
      end

      context "when response signature is incorrect" do
        it "raises an InvalidSignature exception" do
          response = double(:meta => { "x-sponsorpay-response-signature" => "xxx7766x778xx888x" }, :read => sample_json)
          client.stub(:open).and_return response

          lambda {
            client.fetch_offers raw_params
          }.should raise_exception InvalidSignature
        end
      end
    end

    describe "#prepare_params" do
      class Client
        public :prepare_params
      end

      it "returns a params string with the hashkey at the end" do
        params = client.prepare_params raw_params
        params.should be_eql "appid=157&device_id=2b6f0cc904d137be2e1730235f5664094b831186&ip=212.45.111.17&locale=de&page=2&ps_time=1312211903&pub0=campaign2&timestamp=1312553361&uid=player1&hashkey=7a2b1604c03d46eec1ecd4a686787b75dd693c4d"
      end
    end
  end
end
