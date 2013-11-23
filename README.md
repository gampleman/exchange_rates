# ExchangeRates

ExchangeRates is a Ruby Gem that allows currency conversion between a number of currencies and allows a historical overview of the currencies. It takes its information from the [European Central Banks historical feed](
http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml).

A demo application can be seen running at http://exchange-rates.herokuapp.com and the source code is [available here](https://github.com/gampleman/exchange_rates/blob/master/example.rb).

## Installation

Add this line to your application's Gemfile:

    gem 'exchange_rates'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install exchange_rates

## Usage

The first task that the programmer must use is to obtain the data source. The library assumes it will be in `./exchange-rates.xml`, however the path can be set via the environment variable `EXCHANGE_RATE_FILE`, which should point to the exchange rate file. This file can be downloaded from the [ECB website](http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml). 

You can add this to your crontab to automatically download the updated files (where MY_PROJECT_PATH is an absolute path to your project). 

    @daily curl -o MY_PROJECT_PATH/exchange-rates.xml http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml >/dev/null 2>&1

Finally if you have a different datasource, you can simply parse it and call `ExchangeRates.set_rates(data, base_currency)`, where `data` will be your currency data organized by date and `base_currency` will be the currency code to which your rates are relative to. For example:

    ExchangeRates.set_rates({
       Date::civil(2013, 11, 21) => {
        'EUR' => 0.9472,  # means 1 USD = 0.9472 EUR on the 21st Oct 2013
        'JPY' => 135.83,
        'BGN' => 1.9558,
        'CZK' => 27.197
      },
      Date::civil(2013, 11, 20) => {
        'EUR' => 0.9527,
        'JPY' => 135.2,
        'BGN' => 1.9558,
        'CZK' => 27.329
      }
    }, 'USD')

Then there are three methods you can call:

#### at

`ExchangeRates.at(date, from_currency, to_currency)` returns the exchange rate from `from_currency` to `to_currency` on the date `date`. Given the data above, the call `ExchangeRates.at(Date::civil(2013, 11, 20), 'JPY', 'CZK')` would return `0.202137574`.

The method throws exceptions if asked about missing dates/currencies.

#### convert

`ExchangeRates.convert(amount, opts)` converts an amount of money between currencies. The options for this method are:

`:from` - from currency, defaults to base_currency (see above, for the default data this is EUR)  
`:to`   - to currency, defaults to base_currency  
`:date` - date at which to perform conversion, defaults to current date

#### over_time

`ExchangeRates.over_time(from, to)` gives a hash of all known dates and the exchange rate between `from` and `to`.

Again given the above data, calling `ExchangeRates.over_time('JPY', 'CZK')` gives `{Date::civil(2013, 11, 21) => 0.200228226, Date::civil(2013, 11, 20) => 0.202137574}`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
