require 'spec_helper'
require 'puppet_community_data/repository'
require 'puppet_community_data/application'

describe Repository do

	CACHE = {}

	#let(:opts) { { :repository_name => "puppetlabs-apache", :repository_owner => "puppetlabs", :module_name => "apache"} }

  def closed_puppet_pull_requests
    CACHE[:closed_puppet_pull_requests] ||= read_request_fixture
  end

  def read_request_fixture
    fpath = File.join(SPECDIR, 'fixtures', 'closed_pull_requests.json')
    JSON.parse(File.read(fpath))
  end

	subject do
    described_class.new(REPO_OPTS)
  end
  
	it "creates instances of ActiveRecord::Base objects" do
    expect(Repository.new).to be_a_kind_of ActiveRecord::Base
  end
  
	#let!(:repo) { Repository.create(:repository_name => "puppetlabs-apache", :repository_owner => "puppetlabs", :module_name => "apache") }
	
	context "#full_name" do 
		it "returns a string" do
			expect(subject.full_name).to be_a_kind_of String
		end
		it "returns the fullname of the repository" do
			expect(subject.full_name).to eql([subject.repository_owner, subject.repository_name].join('/'))
		end
	end
	
	describe "#closed_pull_requests" do
		context "Repository puppetlabs/puppetlabs-apache" do
			let(:github) { PuppetCommunityData::Application.new([]).github_api }
			let(:repo) { Repository.create(REPO_OPTS) }
			subject do
        github.stub(:pull_requests).with(repo.full_name, 'closed').and_return(closed_puppet_pull_requests)
        github.stub(:organization_member?).and_return(true)
        repo.closed_pull_requests(github)
      end
      
      it 'returns an array of pull requests' do
        expect(subject).to be_a_kind_of Array
      end
      it 'the pull requests are represented as Hashes of data' do
        expect(subject[0]).to be_a_kind_of Hash
      end

      it 'stores the correct pull request number' do
        expect(subject[0]["pr_number"]).to eq(290)
      end

      it 'stores the correct repository id' do
        expect(subject[0]["repo_id"]).to eq(repo.id)
      end

      it 'stores the correct merge status' do
        expect(subject[0]["merge_status"]).to eq(true)
      end

      it 'stores the correct open time' do
        expect(subject[0]["time_opened"]).to eq(Chronic.parse('2013-08-09T12:19:56Z').to_time)
      end

      it 'stores the correct close time' do
        expect(subject[0]["time_closed"]).to eq(Chronic.parse('2013-08-09T17:07:53Z').to_time)
      end

      it 'stores whether or not the pull request is from the community' do
        expect(subject[0]["from_community"]).to eq(false)
      end

      it 'stores the state of the pull request (open v closed)' do
        expect(subject[0]["closed_v_open"]).to eq(true)
      end
    end
  end
end