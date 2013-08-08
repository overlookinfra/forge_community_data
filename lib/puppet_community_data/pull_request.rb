require 'sinatra/activerecord'
require 'active_record/base'

class PullRequest < ActiveRecord::Base
	belongs_to :repository, :foreign_key => "repo_id"
  ##
  # Return a new instance given data from the Github API.
  #
  # @param [Hash] pr_data the pull request data from the Github API used to
  #   construct our model of the pull request
  #
  # @return [PullRequest]
  def self.from_github(pr_data)
    key_attributes = {
      :repo_id => pr_data["repo_id"],
      :pull_request_number => pr_data["pr_number"],
    }

    model = self.where(key_attributes).first_or_create do |pr|
      pr.merged_status = pr_data["merge_status"]
      pr.time_closed = pr_data["time_closed"]
      pr.time_opened = pr_data["time_opened"]
      pr.from_community = pr_data["from_community"]
      pr.closed = pr_data["closed_v_open"]
    end
    model
  end
end
