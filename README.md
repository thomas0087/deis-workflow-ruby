Deis Workflow Ruby
==================

Deis Workflow Controller API bindings for Ruby.

Compliant with `Controller API v2.2`.

[![Gem Version](https://badge.fury.io/rb/deis-workflow.svg)](https://badge.fury.io/rb/deis-workflow)

Installing
----------

```bash
$ gem build deis-workflow.gemspec
$ gem install deis-workflow-0.0.1.gem
```

Using
-----

```ruby
> require 'deis-workflow'
> client = DeisWorkflow::Client.new('http://local.deis.app', 'the-secret-auth-token')
> client.apps_list_all
```

Contributing
------------

* Fork the repo
* Create a PR with your changes
* Pester the maintainer to accept your changes
