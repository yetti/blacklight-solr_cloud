# frozen_string_literal: true

require_relative "solr_cloud/version"

module Blacklight
  module SolrCloud
    autoload :Error, "solr_cloud/error"
    autoload :Repository, "solr_cloud/repository"
  end
end
