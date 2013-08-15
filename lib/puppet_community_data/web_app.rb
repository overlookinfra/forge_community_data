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
		attr_reader :repositories
    set :root, File.expand_path('../../../', __FILE__)

    # Extend Sinatra with ActiveRecord database connections.
    register Sinatra::ActiveRecordExtension
    
    before do
    	@repositories = Repository.all.order('module_name ASC')
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
			repo = Repository.where(:module_name => params[:name]).first
			halt 404 unless repo
			repo.to_json
		end

		get '/data/puppet_pulls/?' do
			#PullRequest.select("pull_requests.time_closed AS time, " +
			#										"r.repository_name AS repo, "+
			#										"date_part('day', age(pull_requests.time_closed, pull_requests.time_opened)) AS ttl, "+
			#										"date_part('week', pull_requests.time_closed) AS week, "+
			#										"CASE pull_requests.from_community WHEN true THEN 'Community' ELSE 'Puppet Labs' END AS community, "+
			#										"CASE pull_requests.merged_status WHEN true THEN 'Merged' ELSE 'Closed' END AS merged")
			PullRequest.select("pull_requests.time_closed as time_closed, pull_requests.time_opened as time_opened, pull_requests.from_community as from_community, pull_requests.merged_status as merged_status, r.module_name as module_name")
								 .joins("join repositories as r on pull_requests.repo_id = r.id")
								 .load
								 .to_json
		end

		get '/data/puppet_pulls/:name' do
			repo = Repository.where(:module_name => params[:name]).first	
			halt 404 unless repo
			
			PullRequest.select("pull_requests.time_closed as time_closed, pull_requests.time_opened as time_opened, pull_requests.from_community as from_community, pull_requests.merged_status as merged_status, r.module_name as module_name")
								 .joins("join repositories as r on pull_requests.repo_id = r.id")
								 .first
								 .to_json
		end

  end

end
