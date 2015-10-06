Omnivore.io Ruby Client
=======================

The Omnivore.io Ruby Client is used to interact with the [Omnivore API](https://panel.omnivore.io/docs/api) from Ruby.

Usage
-----

Start by creating a connection to Omnivore with your credentials:

```ruby
require 'omnivore-io'
$omnivore_io = OmnivoreIO::API.new(api_key: "API_KEY_HERE")
```

Now you can make requests to the API.

Requests
--------

*TODO*

Meta
----

Based heavily on [heroku.rb](https://github.com/heroku/heroku.rb), originally authored by geemus (Wesley Beary) and Pedro Belo. Thanks, Heroku!

Released under the [MIT license](http://www.opensource.org/licenses/mit-license.php).