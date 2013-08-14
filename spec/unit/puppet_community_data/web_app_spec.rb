require 'spec_helper'
require 'rack/test'
require 'puppet_community_data/web_app'

describe 'PuppetCommunityData::WebApp' do
	include Rack::Test::Methods
	def app
    PuppetCommunityData::WebApp 
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
	end
	
	describe 'GET /data/repositories/:name' do
		route = "/data/repositories/apache"
		
		it_should_reach_page_for route
		it_should_return_404_for "/data/repositories/foobar"
		it_should_return_json_for route
	end
	
	describe 'GET /data/puppet_pulls/?' do
		route = "/data/puppet_pulls"
		
		it_should_reach_page_for route
		it_should_return_json_for route
	end
	
	describe 'GET /data/puppet_pulls/:name' do
		route = "/data/puppet_pulls/apache"
		
		it_should_reach_page_for route
		it_should_return_404_for "/data/puppet_pulls/foobar"
		it_should_return_json_for route
	end
	
end