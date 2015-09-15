# ConsulDo

Consul key-based leader election and task coordinator.

consul-do is a simple command-line tool that will return a 0 or 1 exit status
depending on wether or not the host it's running on holds the lock for the consul
key in question.  See https://www.consul.io/docs/guides/leader-election.html for a
general overview of the consul leader election process.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'consul_do'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install consul_do

## Usage

    $ consul-do --help
    Usage: consul-do OPTIONS
        -k, --key KEY=consul_do          Coordination key
        -h, --consul-host HOST=localhost Consul hostname
        -p, --consul-port PORT=8500      Consul port
        -t, --token TOKEN                ACL Token
            --http_proxy http://HOST:PORT
                                         Use supplied proxy instead of ENV
        -v, --verbose                    Verbose logging

    $ consul-do -k my_key && echo "do stuff"
    do stuff

    $ consul-do -k not_my_key && echo "don't do stuff"

## Requirements

* http access to a host running Consul Agent
* Write access to the `service/` key [via ACL, token](https://www.consul.io/docs/internals/acl.html), or consul default wide-open permissions.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/goldstar/consul_do.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

