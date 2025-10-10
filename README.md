# Oscar::Activity
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "oscar-activity", git: "https://github.com/BotyglotTeam/oscar-activities", branch: "main"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install oscar-activity
```

## Migrations

This engine ships with database migrations. To install them into your host app and run them, use one of the following options:

1) Copy/install the migrations into your app:

  ```bash
  bin/rails oscar_activities:install:migrations
  ```

2) Run the migrations:

- Run all pending migrations (including this engine's):
  ```bash
  bin/rails db:migrate
  ```

- Run only this engine's migrations using scope:
  ```bash
  bin/rails db:migrate SCOPE=oscar_activities
  ```

## Testing

### Regenerating the dummy app

```bash
rm -rf spec/dummy
cd ../ 
rails new oscar-activity/spec/dummy --skip-active-storage --skip-action-mailer --skip-action-cable --skip-javascript --skip-sprockets --skip-test --database=sqlite3 --skip-kamal --skip-git
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


