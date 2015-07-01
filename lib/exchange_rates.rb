require "exchange_rates/version"
require "nokogiri"

# Exchange Rates is responsible for parsing a locally available XML file
# listing ratios between the base_currency and target currencies. All currencies should
# be provided as strings with their 3 letter code.
class ExchangeRates
  # ExchangeRates.at gives an exchange rate between two currencies at a particular
  # date. Raises exceptions if the dates are out of range of the file or if the
  # currencies are unknown.
  def self.at(date, from, to)
    parse_rates
    if rates = @@rates[date]
      unless from_rate = rates[from]
        if from == @@base_currency
          from_rate = 1.0
        else
          raise "Unknown 'from' currency"
        end
      end
      unless to_rate = rates[to]
        if to == @@base_currency
          to_rate = 1.0
        else
          raise "Unknown 'to' currency"
        end
      end
      to_rate / from_rate
    else
      raise "Date out of known dates."
    end
  end

  # Converts an amount of money between currencies. The options for this method are:
  #
  #    from - from currency, defaults to base_currency (typically EUR)
  #    to   - to currency, defaults to  base_currency (typically EUR)
  #    date - date at which to perform conversion, defaults to latest available date in dateset
  def self.convert(amount, opts = {})
    parse_rates
    options = {from: @@base_currency, to: @@base_currency, date: @@rates.keys.sort.reverse.first}.merge(opts)
    amount.to_f * at(options[:date], options[:from], options[:to])
  end

  # Calculates exchange rates between two currencies over all available dates.
  def self.over_time(from, to)
    parse_rates
    results = {}
    @@rates.each do |date, rates|
      results[date] = self.at(date, from, to)
    end
    results
  end

  # Reads and parses the XML data feed providing the underlying data source.
  # The data source is currently assumed to be in the format of the European
  # Central Bank feed accesible at <http://www.ecb.europa.eu/stats/eurofxref/eurofxref­hist­90d.xml>
  # which provides a 90 day history of exchange rates. It is assumed that this
  # file is saved locally, best through a cron tab (see README).
  # If a different source is to be used, call the `set_rates` method.
  def self.parse_rates
    @@rates ||= nil
    return @@rates if @@rates
    @@base_currency = 'EUR'
    rate_file = ENV['EXCHANGE_RATE_FILE'] || './exchange-rates.xml'
    if File.exist?(rate_file)
      doc = Nokogiri::XML(File.read(rate_file))
    else
      doc = Nokogiri::XML(fetch_rates!)
    end
    @@rates = {}
    doc.css('Cube>Cube[time]').each do |day|
      time = Date.parse day.attr('time')
      @@rates[time] = {}
      day.css('Cube').each{ |c|
        @@rates[time][c.attr('currency')] = c.attr('rate').to_f
      }
    end
    @@rates
  end

  # Goes and makes a request to download latest ECB data
  def self.fetch_rates!
    rates = Net::HTTP.get URI.parse 'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml'
    File.write(ENV['EXCHANGE_RATE_FILE'] || './exchange-rates.xml', rates)
    rates
  end

  # Set custom rates data. The data should be a hash of hashes, where the keys in the
  # outer hash are Date objects and the keys in the inner hashes are three letter currency
  # codes. The values are floats showing the exchange rate between a currency and the base
  # currency. This second argument should be the base currency to which all values are relative
  # to.
  def self.set_rates(rates, base = 'EUR')
    @@rates = rates
    @@base_currency = base
  end

  # Outputs an array of dates included in the current data set.
  def self.available_dates
    parse_rates
    @@rates.keys
  end

  # Outputs an array of supported currencies.
  def self.available_currencies
    parse_rates
    @@rates.first[1].keys + [@@base_currency]
  end

end
