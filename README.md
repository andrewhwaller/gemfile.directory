# gemfile.directory

[gemfile.directory](https://gemfile.directory) is a directory of Ruby gemfiles that are used in your favorite Ruby and Rails projects!

Originally created by [@Shpigford](https://twitter.com/Shpigford) and [friends](https://github.com/Shpigford/gemfile.directory/graphs/contributors).
Maintained and hosted by [@andrewhwaller](https://twitter.com/andrewhwaller).

## Codebase

The codebase is vanilla [Rails 8](https://rubyonrails.org/), [Solid Queue](https://github.com/rails/solid_queue), [Solid Cache](https://github.com/rails/solid_cache), [Solid Cable](https://github.com/rails/solid_cable), [Puma](http://puma.io/), and [SQLite](https://www.sqlite.org/). Quite a simple setup.

## Setup

You'll need:

- ruby >3 (specific version is in `Gemfile`)
- GitHub API key (for login)

NOTE: You'll need to create a GitHub OAuth app to get the `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET` values. You can do that [here](https://github.com/settings/applications/new). Use the example ENV file as a template for your own `.env` file.
```shell
cd gemfile.directory
bundle install
rails db:setup
```

You can then run the rails web server:

```shell
bin/dev
```

And visit [http://localhost:3000](http://localhost:3000)

## Contributing

It's still very early days for this so your mileage will vary here and lots of things will break.

But almost any contribution will be beneficial at this point. Check the [current Issues](https://github.com/andrewhwaller/gemfile.directory/issues) to see where you can jump in!

If you've got an improvement, just send in a pull request!

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

If you've got feature ideas, simply [open a new issues](https://github.com/andrewhwaller/gemfile.directory/issues/new)!

## License & Copyright

Released under the MIT license, see the [LICENSE](https://github.com/andrewhwaller/gemfile.directory/blob/main/LICENSE) file. Copyright (c) Sabotage Media LLC.
