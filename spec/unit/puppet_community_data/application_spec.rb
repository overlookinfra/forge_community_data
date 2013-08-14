require 'spec_helper'
require 'puppet_community_data/application'

describe PuppetCommunityData::Application do
  def github_oauth_token
    ENV['PCD_GITHUB_OAUTH_TOKEN'] || 'XXXXXXXXXXX'
  end

  CACHE = {}

  def closed_puppet_pull_requests
    CACHE[:closed_puppet_pull_requests] ||= read_request_fixture
  end

  def read_request_fixture
    fpath = File.join(SPECDIR, 'fixtures', 'closed_pull_requests.json')
    JSON.parse(File.read(fpath))
  end

  subject do
    described_class.new([])
  end

  describe "arguments" do
    let(:argv) { ['--github-oauth-token', '1234token'] }

    subject do
      PuppetCommunityData::Application.new(argv)
    end

    describe '#opts' do
      it 'is an empty hash before runnning' do
        expect(subject.opts).to eq({})
      end

      it 'sets the :github_oauth_token after running' do
        subject.parse_options!
        expect(subject.opts[:github_oauth_token]).to eq '1234token'
      end
    end

    describe 'command line options' do
      it "accepts command line options" do
        subject.parse_options!
      end

      describe 'github_oauth_token' do
        it "returns the string account identifier" do
          subject.parse_options!
          expect(subject.github_oauth_token).to eq("1234token")
        end
      end
    end

    describe '#github_api' do
      it 'is a Octokit::Client instance' do
        expect(subject.github_api).to be_a_kind_of Octokit::Client
      end

      it 'sets auto_traversal to true to get paginated results' do
        expect(subject.github_api.auto_traversal).to eq(true)
      end
    end
=begin
    describe '#generate repositories' do
      let(:names) {['puppetlabs/puppet', 'puppetlabs/facter', 'puppetlabs/hiera']}
      subject{described_class.new([])}

      it "generates the correct number of repositories" do
        subject.generate_repositories(names)
        expect(subject.repositories.length).to eq(3)
      end

      it "generates the correct repository objects" do
        subject.generate_repositories(names)
        expect(subject.repositories[0].full_name).to eq('puppetlabs/puppet')
      end
    end
=end
    describe '#write_pull_requests_to_database' do

      let(:repo) do
        repo = Repository.create
        closed_pr_data = Hash["pr_number" => 1234,
             "repo_id" => repo.id,
             "merge_status" => false,
             "time_closed" => Time.now,
             "time_opened" => Time.now - 3600]
        repo.stub(:closed_pull_requests).and_return([closed_pr_data])
        repo
      end

      before :each do
        subject.stub(:github_api)
        Repository.stub(:all).and_return([repo])
      end

      it "writes the pull request to the database" do
        subject.write_pull_requests_to_database
        expect(PullRequest.where({:pull_request_number => 1234})).to_not be_empty
      end
    end
  end
end
