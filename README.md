# Oscar::Audit
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "oscar-audit", git: "https://github.com/BotyglotTeam/oscar-audit", branch: "main"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install oscar-audit
```

## Migrations

This engine ships with database migrations. To install them into your host app and run them,

  ```bash
  bin/rails oscar_audit:install:migrations
  ```


## Testing

### Regenerating the dummy app

```bash
rm -rf spec/dummy
cd ../ 
rails new oscar-audit/spec/dummy --skip-active-storage --skip-action-mailer --skip-action-cable --skip-javascript --skip-sprockets --skip-test --database=sqlite3 --skip-kamal --skip-git
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


