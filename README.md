# rest-graph [![Build Status](http://travis-ci.org/godfat/rest-graph.png)](http://travis-ci.org/godfat/rest-graph)

by Cardinal Blue <http://cardinalblue.com>

Tutorial on setting up a sample Facebook application with Rails 3
and RestGraph could be found on [samplergthree][]. Instead, if you're
an experienced Ruby programmer, you might also want to look at
[detailed documents][].

[samplergthree]: https://github.com/cardinalblue/samplergthree
[detailed documents]: https://github.com/godfat/rest-graph/blob/master/doc/ToC.md

## LINKS:

* [github](https://github.com/godfat/rest-graph)
* [rubygems](https://rubygems.org/gems/rest-graph)
* [rdoc](http://rdoc.info/projects/godfat/rest-graph)
* [mailing list](http://groups.google.com/group/rest-graph/topics)

## DESCRIPTION:

A lightweight Facebook Graph API client

We have moved the development from rest-graph to [rest-core][].
By now on, we would only fix bugs in rest-graph rather than adding
features, and we would only backport important changes from rest-core
once in a period. If you want the latest goodies, please see [rest-core][]
Otherwise, you can stay with rest-graph with bugs fixes.

[rest-core]: https://github.com/godfat/rest-core

## FEATURES:

* Simple Graph API call
* Simple FQL call
* Utility to extract access_token and check sig in cookies/signed_request

## REQUIREMENTS:

* Tested with MRI 1.8.7 and 1.9.2 and Rubinius 1.2.2.
  Because of development gems can't work well on JRuby,
  let me know if rest-graph is working on JRuby, thanks!

* (must) pick one HTTP client:
  - gem install rest-client
  - gem install em-http-request

* (optional) pick one JSON parser/generator:
  - gem install yajl-ruby
  - gem install json
  - gem install json_pure

* (optional) parse access_token in HTTP_COOKIE
  - gem install rack

* (optional) to use rest-graph/test_util
  - gem install rr

## INSTALLATION:

    gem install rest-graph

Or if you want development version, put this in Gemfile:

    gem 'rest-graph', :git => 'git://github.com/godfat/rest-graph.git',
                      :submodules => true

Or as a Rails2 plugin:

    ./script/plugin install git://github.com/godfat/rest-graph.git

## QUICK START:

    require 'rest-graph'
    rg = RestGraph.new(:access_token => 'myaccesstokenfromfb')
    rg.get('me')
    rg.get('me/likes')
    rg.get('search', :q => 'taiwan')

### Obtaining an access token

If you are using Rails, we recommend that you include a module called
RestGraph::RailsUtil into your controllers. (Your code contributions
for other Ruby frameworks would be appreciated!). RestGraph::RailsUtil
adds the following two methods to your controllers:

    rest_graph_setup:   Attempts to find an access_token from the environment
                        and initializes a RestGraph object with it.
                        Most commonly used inside a filter.

    rest_graph:         Accesses the RestGraph object by rest_graph_setup.

### Example usage:

    class MyController < ActionController::Base
      include RestGraph::RailsUtil
      before_filter :setup

      def myaction
        @medata = rest_graph.get('me')
      end

      private
      def setup
        rest_graph_setup(:app_id               => '123',
                         :canvas               => 'mycanvas',
                         :auto_authorize_scope => 'email')
                         # See below for more options
      end
    end

### Default setup

New RestGraph objects can read their default setup configuration from a
YAML configuration file. Which is the same as passing to rest_graph_setup.

* [Example](test/config/rest-graph.yaml)

To enable, just require anywhere:

    require 'rest-graph'

Or if you're using bundler, add this line into Gemfile:

    gem 'rest-graph'

## SETUP OPTIONS:

Here are ALL the available options for new instance of RestGraph.

    rg = RestGraph.new(
           :access_token  => TOKEN                        , # default nil
           :graph_server  => 'https://graph.facebook.com/', # this is default
           :old_server    => 'https://api.facebook.com/'  , # this is default
           :accept        => 'text/javascript'            , # this is default
           :lang          => 'en-us'                      , # affect search
           :auto_decode   =>  true                        , # decode by json
                                                            # default true
           :app_id        => '123'                        , # default nil
           :secret        => '1829'                       , # default nil

           :cache         => {}                           ,
           # A cache for the same API call. Any object quacks like a hash
           # should work, and Rails.cache works, too. (because of a patch in
           # RailsUtil)

           :error_handler => lambda{|hash| raise RestGraph::Error.new(hash)},
           # This handler callback is only called if auto_decode is
           # set to true, otherwise, it's ignored. And raising exception
           # is the default unless you're using RailsUtil and enabled
           # auto_authorize. That way, RailsUtil would do redirect
           # instead of raising an exception.

           :log_method    => method(:puts),
           # This way, any log message would be output by puts. If you want to
           # change the log format, use log_handler instead. See below:

           :log_handler   => lambda{ |event|
             Rails.logger.
               debug("Spent #{event.duration} requesting #{event.url}")})
           # You might not want to touch this if you're using RailsUtil.
           # Otherwise, the default behavior is do nothing. (i.e. no logging)

And here are ALL the available options for rest_graph_setup. Note that all
options for RestGraph instance are also valid options for rest_graph_setup.

    rest_graph_setup(#
                     # == All the above RestGraph options, plus
                     #
                     :canvas                 => 'mycanvas', # default ''
                     :auto_authorize         => true      , # default false
                     :auto_authorize_scope   => 'email'   , # default ''
                     :auto_authorize_options => {}        , # default {}
                     # auto_authorize means it will do redirect to oauth
                     # API automatically if the access_token is invalid or
                     # missing. So you would like to setup scope if you're
                     # using it. Note that: setting scope implies setting
                     # auto_authorize to true, even it's false.

                     :ensure_authorized      => false     , # default false
                     # This means if the access_token is not there,
                     # then do auto_authorize.

                     :write_session          => true      , # default false
                     :write_cookies          => false     , # default false
                     :write_handler          =>
                       lambda{ |fbs| @cache[uid] = fbs }  , # default nil
                     :check_handler          =>
                       lambda{       @cache[uid] })         # default nil
                     # If we're not using Facebook JavaScript SDK,
                     # then we'll need to find a way to store the fbs,
                     # which contains access_token and/or user id. In a
                     # standalone site or iframe canvas application, you might
                     # want to just use the Rails (or other framework) session

### Alternate ways to setup RestGraph:

1. Set upon RestGraph object creation:

        rg = RestGraph.new :app_id => 1234

2. Set via the rest_graph_setup call in a Controller:

        rest_graph_setup :app_id => 1234

3. Load from a YAML file

        require 'rest-graph/config_util'
        RestGraph.load_config('path/to/rest-graph.yaml', 'production')
        rg = RestGraph.new

4. Load config automatically

        require 'rest-graph'  # under Rails, would load config/rest-graph.yaml
        rg = RestGraph.new

5. Override directly

        module MyDefaults
          def default_app_id
            '456'
            end

          def default_secret
            'category theory'
          end
        end
        RestGraph.send(:extend, MyDefaults)
        rg = RestGraph.new

## API REFERENCE:

### Facebook Graph API:

#### get
    # GET https://graph.facebook.com/me?access_token=TOKEN
    rg.get('me')

    # GET https://graph.facebook.com/me?metadata=1&access_token=TOKEN
    rg.get('me', :metadata => '1')

    # extra options:
    #   auto_decode: Bool # decode with json or not in this API request
    #                     # default: auto_decode in rest-graph instance
    #       timeout: Int  # the timeout for this API request
    #                     # default: timeout in rest-graph instance
    #        secret: Bool # use secret_acccess_token or not
    #                     # default: false
    #         cache: Bool # use cache or not; if it's false, update cache, too
    #                     # default: true
    #    expires_in: Int  # control when would the cache be expired
    #                     # default: nil
    #         async: Bool # use eventmachine for http client or not
    #                     # default: false, but true in aget family
    #       headers: Hash # additional hash you want to pass
    #                     # default: {}
    rg.get('me', {:metadata => '1'}, :secret => true, expires_in => 600)

    # When using eventmachine
    rg.get('me', {:metadata => '1'}, :async => true) do |result|
      # This block is called even on failure
    end

#### post

    rg.post('me/feed', :message => 'bread!')

#### fql

Make an arbitrary [FQL][] query

[FQL]: http://developers.facebook.com/docs/reference/fql/

    rg.fql('SELECT name FROM page WHERE page_id="123"')

#### fql_multi

    rg.fql_multi(:q1 => 'SELECT name FROM page WHERE page_id="123"',
                 :q2 => 'SELECT name FROM page WHERE page_id="456"')

#### old_rest

Call functionality from Facebook's old REST API:

    rg.old_rest(
      'stream.publish',
      { :message    => 'Greetings',
        :attachment => {:name => 'Wikipedia',
                        :href => 'http://wikipedia.org/',
                        :caption => 'Wikipedia says hi.',
                        :media => [{:type => 'image',
                                    :src  => 'http://wikipedia.org/logo.png',
                                    :href => 'http://wikipedia.org/'}]
                       }.to_json,
        :action_links => [{:text => 'Go to Wikipedia',
                           :href => 'http://wikipedia.org/'}
                         ].to_json
      },
      :auto_decode => false) # You'll need to set auto_decode to false for
                             # this API request if Facebook is not returning
                             # a proper formatted JSON response. Otherwise,
                             # this could be omitted.

    # Some Old Rest API requires a special access token with app secret
    # inside of it. For those methods, use secret_old_rest instead of the
    # usual old_rest with common access token.
    rg.secret_old_rest('admin.getAppProperties', :properties => 'app_id')

### Utility Methods:

#### parse_???

All the methods that obtain an access_token will automatically save it.

If you have the session in the cookies,
then RestGraph can parse the cookies:

    rg.parse_cookies!(cookies)

If you're writing a Rack application, you might want to parse
the session directly from Rack env:

    rg.parse_rack_env!(env)

#### access_token

    rg.access_token

Data associated with the access_token (which might or might not
available, depending on how the access_token was obtained).

    rg.data
    rg.data['uid']
    rg.data['expires']

#### Default values

Read from the rest-graph.yaml file.

    RestGraph.default_???

### Other ways of getting an access token

#### authorize_url

Returns the redirect URL for authorizing

    # https://graph.facebook.com/oauth/authorize?
    #   client_id=123&redirect_uri=http%3A%2F%2Fw3.org%2F
    rg.authorize_url(:redirect_uri => 'http://w3.org/', :scope => 'email')

#### authorize!

Makes a call to Facebook to convert
the authorization "code" into an access token:

    # https://graph.facebook.com/oauth/access_token?
    #   code=CODE&client_id=123&client_secret=1829&
    #   redirect_uri=http%3A%2F%2Fw3.org%2F
    rg.authorize!(:redirect_uri => 'http://w3.org/', :code => 'CODE')

#### exchange_sessions

Takes a session key from the old REST API
(non-Graph API) and converts to an access token:

    # https://graph.facebook.com/oauth/exchange_sessions?sessions=SESSION
    rg.exchange_sessions(:sessions => params[:fb_sig_session_key])

## CONTRIBUTORS:

* Andrew Liu (@eggegg)
* andy (@coopsite)
* Barnabas Debreczeni (@keo)
* Bruce Chu (@bruchu)
* Ethan Czahor (@ethanz5)
* Florent Vaucelle (@florent)
* Jaime Cham (@jcham)
* John Fan (@johnfan)
* Lin Jen-Shin (@godfat)
* Mariusz Pruszynski (@snicky)
* Nicolas Fouché (@nfo)
* Yutaro Sugai (@hokkai7go)

## LICENSE:

Apache License 2.0

Copyright (c) 2010-2011, Cardinal Blue

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
