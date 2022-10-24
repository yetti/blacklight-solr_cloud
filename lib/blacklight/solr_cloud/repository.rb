# frozen_string_literal: true

require "zk"
require "rsolr"
require "blacklight"
require "blacklight/solr_cloud/error"

module Blacklight
  module SolrCloud
    class Repository < Blacklight::Solr::Repository
      include MonitorMixin

      ZNODE_LIVE_NODES = "/live_nodes"

      private

      def zk
        @zk ||= ZK.new(ENV.fetch("ZK_HOST", "localhost:2181"), {chroot: :do_nothing})
      end

      def collection
        ENV.fetch("SOLR_COLLECTION", "blacklight")
      end

      def collection_state
        get_collection_state
      end

      def all_nodes
        get_all_nodes
      end

      def live_nodes
        get_live_nodes
      end

      def build_connection
        all_urls = determine_node_urls

        ::RSolr.connect(connection_config.merge(adapter: connection_config[:http_adapter], url: select_node(all_urls)))
      end

      def determine_node_urls
        synchronize do
          all_urls = []
          all_nodes.each do |node|
            next unless active_node?(node, live_nodes)

            url = "#{node["base_url"]}/#{collection}"
            all_urls << url
          end

          # Close the Zookeeper connection since we don't need it anymore
          zk.close! unless zk.closed?

          all_urls
        end
      end

      def collection_state_znode_path(collection)
        "/collections/#{collection}/state.json"
      end

      def get_collection_state
        synchronize do
          collection_state_json, _stat = zk.get(collection_state_znode_path(collection), watch: false)
          ::JSON.parse(collection_state_json)[collection]
        end
      end

      def get_live_nodes
        synchronize do
          live_nodes = {}
          zk.children(ZNODE_LIVE_NODES, watch: false).each do |node|
            live_nodes[node] = true
          end

          live_nodes
        end
      end

      def get_all_nodes
        synchronize do
          nodes = collection_state["shards"].values.map do |shard|
            shard["replicas"].values
          end
          nodes.flatten
        end
      end

      def select_node(all_urls)
        url = synchronize do
          all_urls.sample
        end
        raise Blacklight::SolrCloud::NotEnoughNodes unless url

        url
      end

      def active_node?(node, live_nodes)
        live_nodes[node["node_name"]] && node["state"] == "active"
      end
    end
  end
end
