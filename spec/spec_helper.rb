# Add the projects lib directory to our load path so we can require libraries
# within it easily.
dir = File.expand_path(File.dirname(__FILE__))
lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
SPECDIR = dir

require 'rspec'
require 'fileutils'
require 'pathname'
require 'chronic'

# During tests, rspec tests against an empty database. If you need to test against actual 
# data (as in web_app_spec.rb), put 
# 	Repository.create(REPO_OPTS)
# 	PullRequest.create(PR_OPTS)
# in your tests.
REPO_OPTS =	{ 
	:repository_name => "puppetlabs-apache", 
	:repository_owner => "puppetlabs", 
	:module_name => "apache"
}
PR_OPTS = {
	:pull_request_number => 289,
	:merged_status => true,
	:time_opened => (Chronic.parse("2013-08-08T11:15:42Z")).to_time,
	:time_closed => (Chronic.parse("2013-08-08T20:34:07Z")).to_time,
	:from_community => true,
	:closed => true,
	:repo_id => 1
}



Pathname.glob("#{dir}/shared_contexts/*.rb") do |file|
  require file.relative_path_from(Pathname.new(dir))
end

RSpec.configure do |config|
  # config.mock_with :mocha

  config.before :all do
    # ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/active_record.log')
    ActiveRecord::Base.logger.level = 2
    ActiveRecord::Migration.verbose = false
  end

  config.before :each do
    ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
    ActiveRecord::Migrator.up "db/migrate"
  end
end
