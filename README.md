# Unm

This gem interacts with UNM interfaces. Currently it only works with the events
calendar.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'unm'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install unm

## Usage

To use the gem, first create a new `Unm::Calendar` object by passing it a start
and end date, and a format (defaults to CSV, other options are ICAL and XML):

```ruby
calendar = Unm::Calendar.new(Date.today, Date.today + 365, "ICAL")
```

Then perform the request (returns HTTParty request, use `body` method to
retrieve raw string):

```ruby
request = calendar.get
puts calendar.body
# Probably outputs some super long iCalendar string
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/unm/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
