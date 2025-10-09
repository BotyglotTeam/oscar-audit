# Oscar::Activity
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "oscar-activity"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install oscar-activity
```

## Testing

### Regenerating the dummy app

```bash
rm -rf spec/dummy
cd ../ 
rails new oscar-activity/spec/dummy --skip-active-storage --skip-action-mailer --skip-action-cable --skip-javascript --skip-sprockets --skip-test --database=sqlite3 --skip-kamal --skip-git
```

Now wire the dummy app to your engine:

In `spec/dummy/Gemfile`, add:
```ruby
gem "oscar-activity", path: "../.."
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


