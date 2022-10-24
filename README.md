# Blacklight SolrCloud Repository

A Blacklight repository to connect with a collection on a ZooKeeper managed SolrCloud cluster.

The main concepts for this gem come from the [rsolr-cloud](https://github.com/enigmo/rsolr-cloud) gem.
Unfortunately that library is abandoned and relies on RSolr v1, whilst Blacklight uses v2.

## Usage

This repository requires the following ENV variables be defined in the Blacklight/Arclight application:

* `ZK_HOST` - ZooKeeper connection string
* `SOLR_COLLECTION` - name of the Solr collection

## Installation

Add this line to your application's Gemfile, replacing `[choose a tag]` with an actual release tag.

```ruby
gem "blacklight-solr_cloud", git: "https://github.com/nla/blacklight-solrcloud-repository", tag: '[choose a tag]'
```

And then execute:

```bash
$ bundle install
```

## Contributing

### Setup

`bin/setup` will configure Bundler to install gems into the `vendor/bundle` directory and install all dependencies.

    ⚠️ Installing gems into `vendor/bundle` serves to isolate the versions of gems used in this project from other Ruby projects on your development machine.

#### Containers

Specs are executed against a local SolrCloud cluster. You will need [Podman](https://podman.io/)
to create a container for this cluster using the `docker-compose.yml` file in the `solr` directory.

Create local Solr cluster:

```bash
podman-compose -f ./solr/docker-compose.yml up -d
```

Destroy container and volumes when finished:

```bash
podman-compose -f ./solr/docker-compose.yml down --volumes
```

### Testing

There is a `bin/ci` script that will create/teardown the cluster, run specs, perform linting and security analysis.

You can otherwise run each command in that script individually if you wish.

## License
The gem is available as open source under the terms of the [Apache 2 License](https://opensource.org/licenses/Apache-2.0).
