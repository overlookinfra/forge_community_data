require 'sinatra'
require 'sinatra/activerecord'
require 'json'
require 'httparty'
require 'puppet_community_data/pull_request'
require 'puppet_community_data/application'

module PuppetCommunityData
	include HTTParty
	base_uri "http://forgeapi.puppetlabs.com"
  class WebApp < Sinatra::Base

    set :root, File.expand_path('../../../', __FILE__)

    # Extend Sinatra with ActiveRecord database connections.
    register Sinatra::ActiveRecordExtension
    
    before do
    	@repositories = Repositories.all.order('module_name ASC')
    end

    get '/' do
      erb :main, :locals => { :module_name => '' }
    end

		get '/modules/:name' do
			repo = Repository.where(:module_name => params[:name]).first
			halt 404 unless repo	
			
			erb :module, locals: { module_name: params[:name], repo_owner: repo.repository_owner, repo_name: repo.repository_name }
		end

		get '/data/repositories' do
			if params[:query]
				Repository.where("repository_name like ?", "%#{params[:query]}%").order('module_name ASC').to_json
			else
				Repository.all.order('module_name ASC').to_json
			end
		end
	
		get '/data/repositories/:name' do
			

			Repository.where(:module_name => params[:name]).to_json
		end

		get '/data/puppet_pulls/?' do
			puppet_pulls = PullRequest.all
			pull_requests = Array.new
			puppet_pulls.each do |pr|

				from_community = "Puppet Labs"
				from_community = "Community" if pr.from_community

				merged = "Closed"
				merged = "Merged" if pr.merged_status

				pull_requests.push(Hash["close_time" => pr.time_closed,
																"repo_name" => pr.repository.repository_name,
																"ttl" => ((pr.time_closed - pr.time_opened)/86400).to_i,
																"merged" => merged,
																"community" => from_community])
			end

			pull_requests.to_json
		end

		get '/data/puppet_pulls/:name' do
			repo = Repository.where(:module_name => params[:name]).first
			halt 404 unless repo		
			puppet_pulls = PullRequest.where(:repo_id => repo.id)
			pull_requests = Array.new
			puppet_pulls.each do |pr|

				from_community = "Puppet Labs"
				from_community = "Community" if pr.from_community

				merged = "Closed"
				merged = "Merged" if pr.merged_status

				pull_requests.push(Hash["close_time" => pr.time_closed,
																"repo_name" => pr.repository.repository_name,
																"ttl" => ((pr.time_closed - pr.time_opened)/86400).to_i,
																"merged" => merged,
																"community" => from_community])
			end

			pull_requests.to_json
		end

  end

end
