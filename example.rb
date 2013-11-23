# encoding: utf-8

# This is an example Sinatra app that runs as a web interface for ExchangeRates.
# You can see it in action at http://exchange-rates.herokuapp.com.
# It assumes the data file in the default location.

require 'json'
require 'sinatra'
require 'exchange_rates'

get '/' do
  erb :index
end

get '/rates.json' do
  amount = ExchangeRates.convert(params[:amount], from: params[:from], to: params[:to], date: Date.parse(params[:date]))
  history = ExchangeRates.over_time(params[:from], params[:to])
  {history: history, amount: amount}.to_json
end

__END__

@@ layout
<!DOCTYPE HTML>
<html>
  <head>
    <title>Exchange Rates Demo</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset='utf-8'>
    <link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.0.2/css/bootstrap.min.css" type="text/css" media="screen" title="no title" charset="utf-8">
    <script src="http://code.jquery.com/jquery-1.10.1.min.js"></script>
    <script src="http://code.highcharts.com/highcharts.js" type="text/javascript" charset="utf-8"></script>
    <script src="http://netdna.bootstrapcdn.com/bootstrap/3.0.2/js/bootstrap.min.js"></script>
  </head>
  
  <body>
    <div class="container">
      <div class="row">
        <div class="span12">
          <%=yield%>
        </div>
      </div>
    </div>
    
    <footer>
      <div class="container">
        <div class="row">
          <div class="span6 credits">
            <p>Copyright <%=Date.today.strftime('%Y')%> <a href="http://gampleman.eu">Jakub Hampl</a>.</p>
          </div>
        </div>
      </div>
    </footer>
  </body>
</html>

@@ index
<h1>FX-u-like</h1>

<form action="/rates.json" role=form>
  <div class="row">
    <div class="col-sm-6">
      <div class="form-group">
        <label for="amount">Amount</label>
        <input type="number" class="form-control" id="amount" name="amount" value="1.0">
      </div>
      
      <div class="form-group">
        <label for="from">From</label>
        <select name="from" id="from" class="form-control">
          <% ExchangeRates.available_currencies.each do |currency|%>
          <option value="<%=currency%>"><%=currency%></option>
          <% end %>
        </select>
      </div>
    </div>
    
    <div class="col-sm-6">
      <div class="form-group">
        <label for="date">Date</label>
        <select name="date" id="date" class="form-control">
          <% ExchangeRates.available_dates.each do |date|%>
          <option value="<%=date%>"><%=date%></option>
          <% end %>
        </select>
      </div>
      <div class="form-group">
        <label for="to">To</label>
        <select name="to" id="to" class="form-control">
          <% ExchangeRates.available_currencies.each do |currency|%>
          <option value="<%=currency%>"><%=currency%></option>
          <% end %>
        </select>
      </div>
    </div>
    
  </div>
  
  <button type="submit" class="btn btn-default">Submit</button>
</form>

<div id="results">
  <h1 class="amount"></h1>
  <div id="history"></div>
</div>

<script>
$(function() {
  $('form').submit(function() {
    $.get('/rates.json', $(this).serialize(), function(data) {
      $('.amount').text(""+data["amount"].toFixed(3)+" "+$('#to').val());
      // process data for chart
      var chart_data = [];
      for(var date in data['history']) {
        chart_data.push([Date.parse(date), data['history'][date]]);
      }
      $('#history').highcharts({
        series: [{
          data: chart_data
        }],
        title: {text: "History of rates between "+$('#from').val() + ' and '+$('#to').val()},
        xAxis: {
          title: {text: 'Date'},
          type: 'datetime'
        },
        yAxis: {
          title: { text: 'Rate' }
        },
        chart: {
          type: 'spline'
        },
        legend: false,
        credits: false
      });
    }, 'json');
    return false;
  });
});
</script>