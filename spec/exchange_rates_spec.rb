require "exchange_rates"

describe ExchangeRates do
  
  before(:all) do
    File.open('/tmp/currencies.xml', 'w') {|file| file.write(SAMPLE_XML)}
    ENV['EXCHANGE_RATE_FILE'] = '/tmp/currencies.xml'
  end
  
  it "parses the XML data format correctly" do
    ExchangeRates.parse_rates.should eq(SAMPLE_DATA)
  end
  
  it "should get correct to EUR rates" do
    ExchangeRates.at(DATE1, 'CZK', 'EUR').should eq(1.0/27.197)
  end
  
  it "should get correct from EUR rates" do
    ExchangeRates.at(DATE1, 'EUR', 'CZK').should eq(27.197)
  end
  
  it "should get correct cross rates" do
    ExchangeRates.at(DATE1, 'JPY', 'BGN').should eq(1.9558/135.83)
  end
  
  it "should raise exceptions when out of range" do
    expect{ ExchangeRates.at(Date::civil(2012, 11, 21), 'JPY', 'BGN') }.to raise_error
  end
  
  it "should convert currencies accurately" do 
    ExchangeRates.convert(123, date: DATE1, from: 'CZK').should eq(123.0/27.197)
  end
  
  it "should spread data over time" do
    ExchangeRates.over_time('EUR', 'CZK').should eq({Date::civil(2013, 11, 20) => 27.329, DATE1 => 27.197})
  end  
  
  it "should give the list of supported currencies" do
    ExchangeRates.available_currencies.should eq(%w[USD JPY BGN CZK EUR])
  end
  
  it "should give the list of supported dates" do
    ExchangeRates.available_dates.should eq([DATE1, Date::civil(2013, 11, 20)])
  end
end


DATE1 = Date::civil(2013, 11, 21)

SAMPLE_XML = '<?xml version="1.0" encoding="UTF-8"?><gesmes:Envelope xmlns:gesmes="http://www.gesmes.org/xml/2002-08-01" xmlns="http://www.ecb.int/vocabulary/2002-08-01/eurofxref"><gesmes:subject>Reference rates</gesmes:subject><gesmes:Sender><gesmes:name>European Central Bank</gesmes:name></gesmes:Sender><Cube><Cube time="2013-11-21"><Cube currency="USD" rate="1.3472"/><Cube currency="JPY" rate="135.83"/><Cube currency="BGN" rate="1.9558"/><Cube currency="CZK" rate="27.197"/></Cube>
<Cube time="2013-11-20"><Cube currency="USD" rate="1.3527"/><Cube currency="JPY" rate="135.2"/><Cube currency="BGN" rate="1.9558"/><Cube currency="CZK" rate="27.329"/></Cube>
</Cube></gesmes:Envelope>'

SAMPLE_DATA = {
   DATE1 => {
    'USD' => 1.3472,
    'JPY' => 135.83,
    'BGN' => 1.9558,
    'CZK' => 27.197
  },
  Date::civil(2013, 11, 20) => {
    'USD' => 1.3527,
    'JPY' => 135.2,
    'BGN' => 1.9558,
    'CZK' => 27.329
  }
}