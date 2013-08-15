require 'spec_helper'
require 'rack/test'
require 'puppet_community_data/web_app'

describe 'PuppetCommunityData::WebApp' do
	include Rack::Test::Methods
	def app
    PuppetCommunityData::WebApp 
  end
  
  def expected_repo_hash
  	expected ={}
  	REPO_OPTS.each { |k,v| expected[k.to_s] = v }
  	expected
  end

  def expected_pr_hash
		{
  		"time_closed" => PR_OPTS[:time_closed].utc.strftime("%Y-%m-%dT%H:%M:%SZ"),
  		"time_opened" => PR_OPTS[:time_opened].utc.strftime("%Y-%m-%dT%H:%M:%SZ"),
  		"from_community" => PR_OPTS[:from_community],
  		"merged_status" => PR_OPTS[:merged_status],
  		"module_name" => REPO_OPTS[:module_name]
  	}
  end
  
	before(:each) do
		Repository.create(REPO_OPTS)
  	PullRequest.create(PR_OPTS)
	end	

	def self.it_should_reach_page_for route
		it "reaches a page" do
			get route
			last_response.should be_ok
		end
	end

	def self.it_should_return_404_for route
		it "returns 404 if invalid module name" do
			get route
			last_response.should be_not_found
		end
	end
	
	def self.it_should_return_json_for route
		it "returns JSON" do
			get route
			expect { JSON.parse(last_response.body) }.to_not raise_error
		end
	end
	
	def self.it_should_return_json_array_for route
		it "returns JSON array" do
			get route
			result = JSON.parse(last_response.body)
			result.should be_an(Array)
		end
	end
	
	def self.it_should_return_json_hash_for route
		it "returns JSON hash" do
			get route
			result = JSON.parse(last_response.body)
			result.should be_a(Hash)
		end
	end
	
	def self.it_should_return_repo_data_for route
		it "returns repository data" do
			get route
			result = JSON.parse(last_response.body)
			result = result.first if result.is_a? Array
			result.should include(expected_repo_hash)
		end
	end
	
	def self.it_should_return_pr_data_for route
		it "returns pull request data" do
			get route
			result = JSON.parse(last_response.body)
			result = result.first if result.is_a? Array
			result.should include(expected_pr_hash)
		end
	end
	
	describe "GET /" do
		route = "/"
		
		it_should_reach_page_for route
	
	end

	describe "GET /modules/:name" do
		route = "/modules/apache"
		
		it_should_reach_page_for route
		it_should_return_404_for "/modules/foobar"
	
	end
	
	describe 'GET /data/repositories' do
		route = "/data/repositories"
		
		it_should_reach_page_for route
		it_should_return_json_for route
		it_should_return_json_array_for route
		it_should_return_repo_data_for route
	end
	
	describe 'GET /data/repositories/:name' do
		route = "/data/repositories/apache"
		
		it_should_reach_page_for route
		it_should_return_404_for "/data/repositories/foobar"
		it_should_return_json_for route
		it_should_return_json_hash_for route
		it_should_return_repo_data_for route
	end
	
	describe 'GET /data/puppet_pulls/?' do
		route = "/data/puppet_pulls"
		
		it_should_reach_page_for route
		it_should_return_json_for route
		it_should_return_json_array_for route
		it_should_return_pr_data_for route
	end
	
	describe 'GET /data/puppet_pulls/:name' do
		route = "/data/puppet_pulls/apache"
		
		it_should_reach_page_for route
		it_should_return_404_for "/data/puppet_pulls/foobar"
		it_should_return_json_for route
		it_should_return_json_array_for route
		it_should_return_pr_data_for route
	end
	
end