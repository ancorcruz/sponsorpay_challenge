require 'spec_helper'

describe "SponsorPay Offers" do
  it "responds to root page" do
    get '/'
    last_response.should be_ok
  end
end
