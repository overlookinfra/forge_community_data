require 'httparty'
require 'json'
require 'yaml'
require 'erb'
require 'logger'
require 'sinatra/activerecord/rake'
require 'puppet_community_data/application'

require "bundler/gem_tasks"

desc "Setup the database connection environment"
task :environment do
  ENV['RACK_ENV'] ||= 'production'
  rack_env = ENV['RACK_ENV']

  # Make sure heroku logging works
  STDOUT.sync = true
  STDERR.sync = true
  logger = Logger.new(STDOUT)

  # Configure the ActiveRecord library to use heroku compatible STDERR logging.
  ActiveRecord::Base.logger = logger.clone

  # Heroku overwrites our database.yml file with an ERB tempalte which
  # populates the database connection information automatically.  We need to
  # make sure to parse the file as ERB and not YAML directly.
  dbconfig = YAML.load(ERB.new(File.read('config/database.yml')).result)
  logger.debug("config/database.yml is #{JSON.generate(dbconfig)}")

  # establish_connection is what actually connects to the database server.
  ActiveRecord::Base.establish_connection(dbconfig[rack_env])
end

namespace :db do
  # This will use the migration as implemented in ActiveRecordTasks
  task :migrate => :environment
  task :rollback => :environment
end

namespace :job do

	# First runs the repositories task, then updates the pull_requests table accordingly
	# so long as it's Sunday. If you don't want heroku updating the pull_requests table every
	# day (and thus racking up our bill for dyno hours), tell heroku to run this task daily
  desc "Import pull requests into the DB if it's Sunday"
  task :import_if_sunday => [:environment, :repositories] do |t|

    logger = Logger.new(STDOUT)

    if not Date.today.sunday?
      logger.debug("Data not imported since today is not Sunday")
      Kernel.exit(true)
    end
    
    app = PuppetCommunityData::Application.new
    app.setup_environment
    app.write_pull_requests_to_database
  end

	# Like above, but runs whenever you want. Don't have heroku run this every day if you don't
	# want large bills for lots of dyno hours
  desc "Import pull requests into the DB"
  task :import => [:environment, :repositories] do |t|

    app = PuppetCommunityData::Application.new
    app.setup_environment
    app.write_pull_requests_to_database
  end
  
  # Gets all puppet forge modules, and adds their github repo data to the repositories table
  # (if they aren't already in the table)
  # Gets repoistory name/ owner login by extracting that from the source url. Note that this 
  # task will skip over anymodules whose source url doesn't look like this (stuff in parentheses
  # is optional):
  # http(s)://github.com/<github_username>/<repository_name>(.git)(/)
  desc "Import repository data for Puppet Forge modules"
  task :repositories => :environment do |t|
  	response = HTTParty.get("http://forgeapi.puppetlabs.com/v2/users/puppetlabs/modules")
		return nil unless response.success?
		response.each do |mod|
			# You may want to just add the field github_repo_name to the forge database instead of doing this next bit...
			next unless mod["source_url"].include? "github"
			mod["source_url"].chomp! "/"
			mod["source_url"].chomp! ".git"
			next unless mod["source_url"] =~ /github.com\/[a-zA-Z0-9][a-zA-Z0-9-]*\/[a-zA-Z0-9_.-]+$/
			name = mod["source_url"].sub /(https?:\/\/)?github.com\//, ''
			puts "#{mod['name']}, #{mod['source_url']}, #{name}"
			
			tmp = name.split "/"
			
			Repository.where( :module_name => mod["name"], :repository_owner => tmp[0], :repository_name => tmp[1] ).first_or_create
		end
  end
end
