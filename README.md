# Pull

Creates Github pull requests from the command line.

## Installation

Add this line to your application's Gemfile:

    gem 'pull'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pull

## Usage

You can pull to any branch in your repo or even to the parent repo if your repo is a fork of another repo

    # This breaks if your branch isn't on Github.
    $ git push origin your-branch
    $ pull parent:master

    or
    
    $ pull parent:feature-branch

    or 
    
    $ pull master # master branch of your own repo

    or
    
    $ pull --ask # gets a list of all branches where you can pull to including parent repo branches


## Thanks

Thanks to Nick Quaranto ([qrush](https://github.com/qrush)) for writing the
first version of this script and leaving a version of it in every project he
touched.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
