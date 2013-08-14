require 'spec_helper'
require 'puppet_community_data/pull_request'
require 'chronic'

describe PullRequest do
  it "creates instances of ActiveRecord::Base objects" do
    expect(PullRequest.new).to be_a_kind_of ActiveRecord::Base
  end

  context "#from_github" do
    let(:close_time) {Chronic.parse('2013-04-17').to_time}
    let(:open_time) {Chronic.parse('2013-01-10').to_time}
    let(:pr_hash) { Hash["pr_number" => 20,
    										 "repo_id" => 1,
                         "merge_status" => true,
                         "time_closed" => close_time,
                         "time_opened" => open_time,
                         "from_community" => false,
                         "close_v_open" => true]}

    it "writes the pull request if it is new" do
      PullRequest.from_github(pr_hash)
      expect(PullRequest.exists?(:pull_request_number => 20,
                                 :repo_id => 1)).to be_true
    end

    it "doesn't write the pull request if it isn't new" do
      PullRequest.create(:pull_request_number => 20,
                         :repo_id => 1,
                         :merged_status => true,
                         :time_closed => close_time,
                         :time_opened => open_time,
                         :from_community => false,
                         :closed => true)
      PullRequest.from_github(pr_hash)
      expect(PullRequest.find_by_sql("select * from pull_requests where id = 1").length).to eq(1)
    end
  end
end
