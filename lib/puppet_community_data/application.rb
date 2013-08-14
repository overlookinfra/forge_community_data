require 'puppet_community_data'
require 'puppet_community_data/version'
require 'puppet_community_data/repository'
require 'puppet_community_data/pull_request'

require 'octokit'
require 'json'
require 'csv'
require 'trollop'

module PuppetCommunityData
  class Application

    attr_reader :opts
    attr_accessor :repositories

    ##
    # Initialize a new application instance.  See the run method to run the
    # application.
    #
    # @param [Array] argv The argument vector to use for options parsing.
    #
    # @param [Hash] env The environment hash to use for options parsing.
    def initialize(argv=ARGV, env=ENV.to_hash)
      @argv = argv
      @env  = env
      @opts = {}
    end

    def setup_environment
      unless @environment_setup
        parse_options!
        @environment_setup = true
      end
    end

    ##
    # run the application.
    def run
      setup_environment
    end

    def version
      PuppetCommunityData::VERSION
    end

    def github_oauth_token
      return @opts[:github_oauth_token]
    end

    def github_api
      @github_api ||= Octokit::Client.new(:auto_traversal => true, :oauth_token => github_oauth_token)
    end
    ##
    # Given an array of repository names as strings,
    # write_pull_requests_to_database will generate repositry objects
    # for each one. Then, it will get a collection of closed pull
    # requests from that repository, and if they are not already in
    # the database, it will add them.
    def write_pull_requests_to_database
    	repositories = Repository.all
      repositories.each do |repo|
        pull_requests = repo.closed_pull_requests(github_api)
        pull_requests.each do |pull_request|
          if pull_request.nil?
            warn "Encounter nil pull request, skipping database entry"
          else
            PullRequest.from_github(pull_request)
          end
        end
      end
    end

    ##
    # parse_options parses the command line arguments and sets the @opts
    # instance variable in the application instance.
    #
    # @return [Hash] options hash
    def parse_options!
      env = @env
      @opts = Trollop.options(@argv) do
        version "Puppet Community Data #{version} (c) 2013 Puppet Labs"
        banner "---"
        text "Gather data from source repositories and produce metrics."
        text ""
        opt :github_oauth_token, "The oauth token to create instange of GitHub API (PCD_GITHUB_OAUTH_TOKEN)",
          :default => (env['PCD_GITHUB_OAUTH_TOKEN'] || '1234changeme')
      end
    end
  end
end
