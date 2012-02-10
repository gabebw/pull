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

The gem assumes that you have a Github remote named "origin".

    # This breaks if your branch isn't on Github.
    $ git push origin your-branch
    $ pull
    Making a pull request for your-branch!

    https://github.com/USER/REPO/pull/1

Voila.

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
