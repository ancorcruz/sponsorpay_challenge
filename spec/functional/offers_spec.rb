require 'spec_helper'

describe "SponsorPay Offers", type: :feature do
  before  do
    visit "/"
    Timecop.freeze
  end

  subject { page }

  describe "request offers" do
    let(:client)     { double("sponsorpay::client") }
    let(:raw_params) {
      {
        "appid"       => "157",
        "uid"         => "player1",
        "ip"          => "109.235.143.113",
        "locale"      => "de",
        "device_id"   => "2b6f0cc904d137be2 e1730235f5664094b 831186",
        "pub0"        => "campaign2",
        "page"        => "2",
        "timestamp"   => Time.now.to_i.to_s,
        "offer_types" => "112",
      }
    }

    before do
      SponsorPay::Client.stub(:new).with(kind_of String).and_return client
      fill_in "uid",  with: "player1"
      fill_in "pub0", with: "campaign2"
      fill_in "page", with: "2"
    end

    context "with one offer as response" do
      let(:offers) { JSON.parse(File.read 'spec/assets/sp_response.json')["offers"] }

      before do
        client.should_receive(:fetch_offers).with(raw_params).once.and_return offers
        click_button "Submit"
      end

      it "responds showing all offers found (1)" do
        should have_content "Tap Fish"
        should have_content "90"
        should have_css "img[@src=\"http://cdn.sponsorpay.com/assets/1808/icon175x175-2_square_60.png\"]"
      end
    end

    context "with no offers as response" do
      let(:offers) { JSON.parse(File.read 'spec/assets/sp_no_offers_response.json')["offers"] }

      before do
        client.should_receive(:fetch_offers).with(raw_params).once.and_return offers
        click_button "Submit"
      end

      it "shows a 'No offers' message" do
        should have_content 'No offers'
      end
    end

    context "with an invalid response signature" do
      before do
        client.should_receive(:fetch_offers).with(raw_params).once.and_raise SponsorPay::InvalidSignature
        click_button "Submit"
      end

      it "shows a 'No offers' message" do
        should have_content 'No offers'
      end
    end
  end
end
