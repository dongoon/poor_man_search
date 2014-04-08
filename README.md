# PoorManSearch

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'poor_man_search'

And then execute:

    $ bundle

## Usage

### Example

A master table : users

| email | name | rank | registered_at |
|------------------|--------------|-----|-------------|
| taro@yamada.example.com | 山田太郎 | 1 | 2013-12-31 23:21:11 |
| hana@yamada.example.com | 山田華 | 3 | 2014-2-28 3:15:00 |
| chad@miller.example.com | Chad Miller | 1 | 2014-2-28 16:23:15 |


Configure like this.

```ruby
class User < ActiveRecord::Base
  extend PoorManSearch::Searchable
  string_search :name, :email
  number_search :rank
  time_search :registered_at
end
```

Search!

```ruby
User.search "yamada"
```
result

| email | name | rank | registered_at |
|------------------|--------------|-----|-------------|
| taro@yamada.example.com | 山田太郎 | 1 | 2013-12-31 23:21:11 |
| hana@yamada.example.com | 山田華 | 3 | 2014-2-28 3:15:00 |



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
