require 'sinatra'
require 'sinatra/activerecord'

require 'json'
require 'httparty'
require 'puppet_community_data/pull_request'
require 'puppet_community_data/application'

# NOTE: in all these routes, the parameter :name refers to the module name, not the repository name

module PuppetCommunityData
	include HTTParty
	base_uri "http://forgeapi.puppetlabs.com"
  class WebApp < Sinatra::Base
		attr_reader :repositories
    set :root, File.expand_path('../../../', __FILE__)

    # Extend Sinatra with ActiveRecord database connections.
    register Sinatra::ActiveRecordExtension
    
    before do
    	@repositories = Repository.all.order('module_name ASC')
    end

		# Displays pr data for all modules
    get '/' do
      erb :main, :locals => { :module_name => '' }
    end
		
		# Displays pr data for a specific module
		get '/modules/:name' do
			repo = Repository.where(:module_name => params[:name]).first
			halt 404 unless repo	
			
			erb :module, locals: { module_name: params[:name], repo_owner: repo.repository_owner, repo_name: repo.repository_name }
		end

		# Returns JSON data for all module repositories
		get '/data/repositories' do
			if params[:query]
				Repository.where("repository_name like ?", "%#{params[:query]}%").order('module_name ASC').to_json
			else
				Repository.all.order('module_name ASC').to_json
			end
		end
	
		# Returns JSON data for specific module repository
		get '/data/repositories/:name' do
			repo = Repository.where(:module_name => params[:name]).first
			halt 404 unless repo
			repo.to_json
		end

		# Returns JSON data for all pull requests on all modules
		get '/data/puppet_pulls/?' do
			start_date = params[:start]
      end_date = params[:end]
      start_date ||= '2011-07-01'
			PullRequest.select("pull_requests.time_closed as time_closed, pull_requests.time_opened as time_opened, pull_requests.from_community as from_community, pull_requests.merged_status as merged_status, r.module_name as module_name")
								 .joins("join repositories as r on pull_requests.repo_id = r.id")
								 .where("pull_requests.time_closed > '#{start_date}'")
								 .load
								 .to_json
		end

		# Returns JSON data for all pull requests on a specific module
		get '/data/puppet_pulls/:name' do
			repo = Repository.where(:module_name => params[:name]).first	
			halt 404 unless repo
			
			start_date = params[:start]
      end_date = params[:end]
      start_date ||= '2011-07-01'
			PullRequest.select("pull_requests.time_closed as time_closed, pull_requests.time_opened as time_opened, pull_requests.from_community as from_community, pull_requests.merged_status as merged_status, r.module_name as module_name")
								 .joins("join repositories as r on pull_requests.repo_id = r.id")
								 .where("pull_requests.time_closed > '#{start_date}'")
								 .load
								 .to_json
		end

  end

end
