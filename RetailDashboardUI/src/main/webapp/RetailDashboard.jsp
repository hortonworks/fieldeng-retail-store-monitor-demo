<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" %> 
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Customer Details</title>
<style type="text/css">
.header1{
	background:-o-linear-gradient(bottom, #415866 5%, #415866 100%);	background:-webkit-gradient( linear, left top, left bottom, color-stop(0.05, #ff0000), color-stop(1, #415866) );
	background:-moz-linear-gradient( center top, #415866 5%, #415866 100% );
	filter:progid:DXImageTransform.Microsoft.gradient(startColorstr="#ff0000", endColorstr="#415866");	background: -o-linear-gradient(top,#415866,bf5f00);

	background-color:#ff0000;
	border:0px solid #000000;
	text-align:center;
	border-width:0px 0px 1px 1px;
	font-size:14px;
	font-family:Arial;
	font-weight:bold;
	color:#ffffff;
}

.header{
	padding-top: 10px;
    padding-bottom: 10px;
    vertical-align: bottom;
    position: relative;
    height: 70px;
    background-color: #333;
    border-bottom: 5px solid #3FAB2A;
}

#brandingLayout {
    position: relative;
    height: 70px;
    padding: 0px 48px 0px 10px;
}

.brandTitle {
    color: #ffffff;
    font-weight: bolder;
    font-size: 1.25em;
    vertical-align: bottom;
    margin-left: 2px;
    margin-right: 0px;
}

.body_container{
	margin-top: 20px;
}

.section_container {
	width: 100%;
	display: inline-block;
}

.top_section {
	width: 100%;
	height: 220px;
	float: left;
	overflow: hidden;
}

.profile_container {
	margin-right: 5px;
	margin-left: 5px;
	margin-bottom: 5px;
	width:45%;
	height: 100%;
	float: left;
	overflow: scroll;
}

div#account_container{
	margin-right: 2px;
	margin-left: 2px;
	margin-top: 2px;
	margin-bottom: 5px;
	padding-top: 10px;
    padding-bottom: 10px;
	border-top: solid 1px #333;
	border-bottom: solid 1px #333;
	background-color: #9CF;
}

div#customer_container{
	margin-right: 2px;
	margin-left: 2px;
	margin-top: 5px;
	margin-bottom: 2px;
	padding-top: 10px;
    padding-bottom: 10px;
	border-top: solid 1px #333;
	border-bottom: solid 1px #333;
	background-color: #FAFAFA;
}

.map_container {
	margin-right: 5px;
	margin-left: 5px;
	margin-bottom: 5px;
	width:45%;
	height: 100%;
	float: left;
}

.charts_section {
	width: 100%;
	height: 210px;
	float: left;
	overflow: hidden;
}

.chart_container {
	margin-top: 5px;
	margin-right: 5px;
	margin-left: 5px;
	width: 45%;
	float: left;
	overflow: hidden;
	border-top: solid 1px #333;
	border-bottom: solid 1px #333;
	border-left: solid 1px #333;
	border-right: solid 1px #333;
}

.table_container {
	margin-top: 5px;
	margin-right: 5px;
	margin-left: 5px;
	width: 45%;
    float: left;
    position: relative;
}

.transaction_table_header {
	font-family: arial;
	margin-right: 2px;
	margin-left: 2px;
	margin-top: 2px;
	border-top: solid 1px #333;
	border-bottom: solid 1px #333;
	border-left: solid 1px #333;
	border-right: solid 1px #333;
	background-color: #9CF;
}

.fraud_table_header {
	font-family: arial;
	margin-right: 2px;
	margin-left: 2px;
	margin-top: 2px;
	border-top: solid 1px #333;
	border-bottom: solid 1px #333;
	border-left: solid 1px #333;
	border-right: solid 1px #333;
	background-color: #ED5C98;
}

.summary_table{
	font-family: arial;
	font-size: 15px;
}

.table_header_container {
	font-family: arial;
	margin-right: 2px;
	margin-left: 2px;
	margin-top: 2px;
	border-top: solid 1px #333;
	border-bottom: solid 1px #333;
	border-left: solid 1px #333;
	border-right: solid 1px #333;
	position: relatiave;
	float: left;
}

.table_cell_container {
	font-family: arial;
	margin-right: 2px;
	margin-left: 2px;
	margin-top: 2px;
	border-top: solid 1px #333;
	border-bottom: solid 1px #333;
	border-left: solid 1px #333;
 	border-right: solid 1px #333;
 	position: relatiave;
	float: left;
}

</style>
<script src="http://code.jquery.com/jquery-1.9.1.js"></script>
<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
<script type="text/javascript" src="https://www.google.com/jsapi"></script>
<script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?key=${mapAPIKey}"></script> 
<script src="https://code.highcharts.com/highcharts.js"></script>
<script src="https://code.highcharts.com/highcharts-more.js"></script>
<script src="https://code.highcharts.com/modules/exporting.js"></script>
<script src="//ajax.googleapis.com/ajax/libs/dojo/1.7.8/dojo/dojo.js"></script>
<script type="text/javascript">
  	console.log("Number of transactions in hisotry: " + ${fn:length(transactionHistory)});
  	dojo.require("dojo.io.script");
  	dojo.require("dojox.cometd");
  	dojo.require("dojox.cometd.longPollTransport");
  
  	var table;
  	var tableData;
  	var cometdHost = "${cometdHost}";
  	var cometdPort = "${cometdPort}";
  	var pubSubUrl = "http://" + cometdHost + ":" + cometdPort + "/cometd";
  	var alertChannel = "/fraudAlert";
    var incomingTransactionsChannel = "/incomingTransactions";
  	var sentimentChannel = "/sentiment";
	var preview = {};
	var markers = {};
	var map;
	var revenueSentimentChart;
	var revenueSentimentChartData;
	var currentRevenue;
	var currentSentiment;
	
	dojo.ready(connectDeviceTopic)
	function connectDeviceTopic(){
			dojox.cometd.init(pubSubUrl);
			dojox.cometd.subscribe("/*", function(message){
				if(message.channel == incomingTransactionsChannel){
					console.log(message);
					
					currentTimeStamp = message.data.timeStamp;
					currentRevenue = currentRevenue + message.data.amount;
					currentSentiment = currentSentiment + message.data.sentiment;
					
					revenueSentimentChartData.addRows([[currentTimeStam, currentRevenue, currentSentiment]]);
					revenueSentimentChart.draw(revenueSentimentChartData, revenueSentimentChartChartOptions);
				}else if(message.channel == alertChannel){
					console.log(message);
				}else{
					console.log(message)
				}	
			});
	  }
	
	function drawRevenueVsSentiment() {
		  revenueSentimentChartData = new google.visualization.DataTable();
		  revenueSentimentChartData.addColumn('string', 'TimeStamp');
		  revenueSentimentChartData.addColumn('number', 'Revenue');
		  revenueSentimentChartData.addColumn('number', 'Sentiment');

		  revenueSentimentChartData.addRows([['0', 0, 0]]);
		  revenueSentimentChartData.addRows([['1', 200, 1]]);
		  revenueSentimentChartData.addRows([['2', 230, 2]]);
		  revenueSentimentChartData.addRows([['3', 280, 3]]);
		  revenueSentimentChartOptions = {
				  chart: {
			          title: 'Real Time Revenue Growth vs Real Time Brand Sentiment'
			        },
			        //width: 350,
			        //height: 150,
			        series: {
			          // Gives each series an axis name that matches the Y-axis below.
			          0: {axis: 'Revenue'},
			          1: {axis: 'Brand Sentiment'}
			        },
			        axes: {
			          // Adds labels to each axis; they don't have to match the axis names.
			          y: {
			            Revenue: {label: 'Revenue ($)'},
			            Sentiment: {label: 'Brand Sentiment'}
			          }
			        }
	   	  };

		  revenueSentimentChart = new google.charts.Line(document.getElementById('details'));
		  revenueSentimentChart.draw(revenueSentimentChartData, revenueSentimentChartOptions);
	  }
	
	function drawRevenueByCategoryChart() {
        var data = google.visualization.arrayToDataTable([
			['Product Category', 'Revenue'],
			<c:forEach items="${revenueByCategory}" var="category">
          		['${category.key}',${category.value}],  
		  	</c:forEach>                                                
		  ['', 0]
        ]);

        var options = {
          title: 'Revenue by Product Category',
          pieHole: 0.3,
        };

        var chart = new google.visualization.PieChart(document.getElementById('chart1'));
        chart.draw(data, options);
      }
	
	function drawRevenueBySubCategoryChart() {
        var data = google.visualization.arrayToDataTable([
			['Product Sub Category', 'Revenue'],
			<c:forEach items="${revenueBySubCategory}" var="subCategory">
          		['${subCategory.key}',${subCategory.value}],  
		  	</c:forEach>                                                
		  ['', 0]
        ]);

        var options = {
          title: 'Revenue by Product Sub Category',
          pieHole: 0.3,
        };

        var chart = new google.visualization.PieChart(document.getElementById('chart2'));
        chart.draw(data, options);
      }
      /*
      function drawMap() {
		var row = 0;        
    	var data = google.visualization.arrayToDataTable([
          ['Lat', 'Long', 'Name', 'Marker'],
          <c:forEach items="${transactionHistory}" var="transaction">
          	<c:if test="${transaction.fraudulent == 'true'}">
				[${transaction.latitude}, ${transaction.longitude}, '${transaction.transactionId}', 'red'],
    	  	</c:if>
			<c:if test="${transaction.fraudulent == 'false'}">
				[${transaction.latitude}, ${transaction.longitude}, '${transaction.transactionId}', 'blue'],
    	  	</c:if>
		  </c:forEach>
		  [${accountDetails.homeLatitude}, ${accountDetails.homeLongitude}, 'Home', 'green']
        ]);
        
    	<c:forEach items="${transactionHistory}" var="transaction">
      		mapRowMappings.set("${transaction.transactionId}", row);
			row++;
	  	</c:forEach>
    	
        var url = 'http://icons.iconarchive.com/icons/icons-land/vista-map-markers/48/';        
        var options = {
                //mapType: 'normal',
                mapType: 'styledMap',
                //mapTypeIds: ['styledMap'],
                showTip: true,
          		icons: {
            		blue: {
              			normal:   url + 'Map-Marker-Ball-Azure-icon.png',
              			selected: url + 'Map-Marker-Ball-Right-Azure-icon.png'
            		},
            		green: {
              			normal:   url + 'Map-Marker-Push-Pin-1-Chartreuse-icon.png',
              			selected: url + 'Map-Marker-Push-Pin-1-Right-Chartreuse-icon.png'
            		},
            		red: {
              			normal:   url + 'Map-Marker-Ball-Pink-icon.png',
              			selected: url + 'Map-Marker-Ball-Right-Pink-icon.png'
            		}
          		},
            	maps: {
              		styledMap: {
                	name: 'Styled Map',
                	styles: [
                  	{featureType: 'poi.attraction',
                   		stylers: [{color: '#fce8b2'}, {visibility: 'off'}]},
                  	{featureType: 'road.highway',
                   		stylers: [{hue: '#0277bd'}, {saturation: -50}, {visibility: 'off'}]},
                  	{featureType: 'road.highway', elementType: 'labels.icon',
                   		stylers: [{hue: '#000'}, {saturation: 100}, {lightness: 50}, {visibility: 'off'}]},
                  	{featureType: 'landscape',
                   		stylers: [{hue: '#259b24'}, {saturation: 10},{lightness: -22},{visibility: 'off'}]}
              		]}
            	}
        	};     
        	map = new google.visualization.Map(document.getElementById('map1'));
        	map.draw(data, options);
      }
      
      function drawTable() {
    	var cssClassNames = {headerRow: 'transaction_table_header'};
    	var cssFraudClassNames = {headerRow: 'fraud_table_header'};
    	legitTableData = new google.visualization.DataTable();
        legitTableData.addColumn('string', 'TransactionId');
        legitTableData.addColumn('string', 'MerchantType');
        legitTableData.addColumn('number', 'Amount');
        legitTableData.addColumn('number', 'Distance');
        
    	fraudTableData = new google.visualization.DataTable();
        fraudTableData.addColumn('string', 'TransactionId');
        fraudTableData.addColumn('string', 'MerchantType');
        fraudTableData.addColumn('number', 'Amount');
        fraudTableData.addColumn('number', 'Distance');
        //data.addColumn('number', 'Date');
		//${transaction.transactionId} ${transaction.merchantType} ${transaction.amount} ${transaction.latitude} ${transaction.longitude}
        fraudTableData.addRows([
			<c:forEach items="${transactionHistory}" var="transaction">
				<c:if test="${transaction.fraudulent == 'true'}">
					['${transaction.transactionId}', '${transaction.merchantType}', ${transaction.amount}, ${transaction.distanceFromPrev}],
          		</c:if>
			</c:forEach>
					[ '', '', 0, 0 ]
          ]);
		
        legitTableData.addRows([
			<c:forEach items="${transactionHistory}" var="transaction">
				<c:if test="${transaction.fraudulent == 'false'}">
					['${transaction.transactionId}', '${transaction.merchantType}', ${transaction.amount}, ${transaction.distanceFromPrev}],
				</c:if>
			</c:forEach>
					[ '', '', 0 , 0]
          ]);
		
        legitTable = new google.visualization.Table(document.getElementById('legitTransaction_table'));
        google.visualization.events.addListener(legitTable, 'select', legitTableSelectHandler);        
        legitTable.draw(legitTableData, {showRowNumber: false, width: '100%', height: '100%', cssClassNames});
        
        fraudTable = new google.visualization.Table(document.getElementById('fraudTransaction_table'));
        google.visualization.events.addListener(fraudTable, 'select', fraudTableSelectHandler);        
        fraudTable.draw(fraudTableData, {showRowNumber: false, width: '100%', height: '100%', cssFraudClassNames});
      }
      
      function drawChart() {
        var data = google.visualization.arrayToDataTable([
			['Merchant', 'Share of Transactions'],
			<c:forEach items="${merchantTypeShare}" var="merchantType">
          		['${merchantType.key}',${merchantType.value}],  
		  	</c:forEach>                                                
		  ['', 0]
        ]);

        var options = {
          title: 'Share of Pruchase by Merchant',
          pieHole: 0.3,
        };

        var chart = new google.visualization.PieChart(document.getElementById('chart1'));
        chart.draw(data, options);
      }
      
      function drawSDChart(){
    	  var elementCheck = document.getElementById('selectedTransId').value 
          if(!elementCheck){
        	  var merchantType = 0;
              var amountMean = 20;
              var amountDev = 20;
              var amount = 20;
              var distanceMean = 20; 
        	  var distanceDev = 20;
        	  var distancePrev = 20;
        	  var timeMean = 20;
      	  	  var timeDev = 20;
      	  	  var time = 20;
          }else{
    	  	var merchantType = document.getElementById('selectedTransMerchType').value;
          	var amountMean = parseFloat(document.getElementById(merchantType +"Mean").value);
          	var amountDev = parseFloat(document.getElementById(merchantType +"Dev").value);
          	var amount = parseFloat(document.getElementById('selectedTransAmount').value);
          	var distanceMean = parseFloat(document.getElementById("distanceMean").value); 
    	  	var distanceDev = parseFloat(document.getElementById("distanceDev").value);
    	  	var distancePrev = parseFloat(document.getElementById("selectedTransDistancePrev").value);
    	  	var timeMean = 60;
    	  	var timeDev = 22;
    	  	var time = 50;
          }
    	  console.log(merchantType + ', ' + amount + ', ' + amountMean + ', ' + amountDev + ', ' + distancePrev + ', ' + distanceMean + ', ' + distanceDev)
          $(function () {

              $('#chart2').highcharts({
                  chart: {
                      type: 'columnrange',
                      inverted: true,
                      width: 450,
                      height: 200
                  },

                  title: {
                      text: 'Customer Transaction Range'
                  },

                  subtitle: {
                      text: ''
                  },

                  xAxis: {
                      categories: ['Amount', 'Distance', 'Time']
                  },

                  yAxis: {
                      title: {
                          text: 'Range Deviation'
                      }
                  },

                  tooltip: {
                      valueSuffix: ''
                  },

                  plotOptions: {
                      columnrange: {
                          dataLabels: {
                              enabled: true,
                              formatter: function () {
                                  
                              }
                          }
                      }
                  },

                  legend: {
                      enabled: false
                  },
    				
                  series: [{
                      name: 'Range',
                      data: [
                             
                          [amountMean-amountDev, amountMean+amountDev],	
                          [distanceMean-distanceDev, distanceMean+distanceDev],
                          [timeMean-timeDev, timeMean+timeDev]
                      	]
                  	},
                  	{
                      type: 'scatter',
               		  name: 'Actual',
                      data: [amount, distancePrev, time]
                   	}
                  ]
              });

          });
      }
      
      function legitTableSelectHandler() {
    	  var selection = legitTable.getSelection();
    	  var message = '';
    	  for (var i = 0; i < selection.length; i++) {
    	    var item = selection[i];
    	    //if (item.row != null && item.column != null) {
    	    //  var str = tableData.getFormattedValue(item.row, item.column);
    	    //  message += '{row:' + item.row + ',column:' + item.column + '} = ' + str + '\n';
    	    if (item.row != null) {
    	      //var str = tableData.getFormattedValue(item.row, 0);
    	      //message += '{row:' + item.row + ', column:none}; value (col 0) = ' + str + '\n';
    	      var selectedTransactionId = legitTableData.getFormattedValue(item.row, 0);
    	      var selectedTransactionMerchType = legitTableData.getFormattedValue(item.row, 1);
    	      var selectedTransactionAmount = legitTableData.getFormattedValue(item.row, 2);
    	      var selectedTransactionDistancePrev = legitTableData.getFormattedValue(item.row, 3);
    	    //} else if (item.column != null) {
    	    //  var str = tableData.getFormattedValue(0, item.column);
    	    //  message += '{row:none, column:' + item.column + '}; value (row 0) = ' + str + '\n';
    	    }
    	  }
    	  if (message == '') {
    	    message = 'nothing';
    	  }
    	  document.getElementById('selectedTransId').value = selectedTransactionId;
    	  document.getElementById('selectedTransMerchType').value = selectedTransactionMerchType;
    	  document.getElementById('selectedTransAmount').value = selectedTransactionAmount;
    	  document.getElementById('selectedTransDistancePrev').value = selectedTransactionDistancePrev;
    	  document.getElementById('chart2').innerHTML = "" ;
    	  drawSDChart();
    	  selectMarker(selectedTransactionId);
    	  //alert('You selected transaction: ' + document.getElementById('selectedTransId').value);
	  }
    	  
	  function fraudTableSelectHandler() {
    	  var selection = fraudTable.getSelection();
    	  var message = '';
    	  for (var i = 0; i < selection.length; i++) {
    	    var item = selection[i];
    	    //if (item.row != null && item.column != null) {
    	    //  var str = tableData.getFormattedValue(item.row, item.column);
    	    //  message += '{row:' + item.row + ',column:' + item.column + '} = ' + str + '\n';
    	    if (item.row != null) {
    	      //var str = tableData.getFormattedValue(item.row, 0);
    	      //message += '{row:' + item.row + ', column:none}; value (col 0) = ' + str + '\n';
    	      var selectedTransactionId = fraudTableData.getFormattedValue(item.row, 0);
    	      var selectedTransactionMerchType = fraudTableData.getFormattedValue(item.row, 1);
    	      var selectedTransactionAmount = fraudTableData.getFormattedValue(item.row, 2);
    	      var selectedTransactionDistancePrev = fraudTableData.getFormattedValue(item.row, 3);
    	    //} else if (item.column != null) {
    	    //  var str = tableData.getFormattedValue(0, item.column);
    	    //  message += '{row:none, column:' + item.column + '}; value (row 0) = ' + str + '\n';
    	    }
    	  }
    	  if (message == '') {
    	    message = 'nothing';
    	  }
    	  document.getElementById('selectedTransId').value = selectedTransactionId;
    	  document.getElementById('selectedTransMerchType').value = selectedTransactionMerchType;
    	  document.getElementById('selectedTransAmount').value = selectedTransactionAmount;
    	  document.getElementById('selectedTransDistancePrev').value = selectedTransactionDistancePrev;
    	  document.getElementById('chart2').innerHTML = "" ;
    	  drawSDChart();
    	  selectMarker(selectedTransactionId);
    	  //alert('You selected transaction: ' + document.getElementById('selectedTransId').value);
	  }	  
      

      function selectMarker(selectedTransactionId){
    	map.setSelection(null);  
    	map.setSelection([{row: mapRowMappings.get(selectedTransactionId), column:null}]);  	  
      }
    	  
      function notifyCustomer(){
    	  if(document.getElementById('selectedTransId').value == ''){
    		  alert("Please select a transaction to notify the customer about.");
    	  }else{
    		  location.href='CustomerOverview?requestType=sendFraudNotice&accountNumber=' + ${accountDetails.accountNumber} + '&fraudulentTransactionId=' + document.getElementById('selectedTransId').value;  
    	  }
      }
      */       
      function loadCharts(){
    	  //if(${accountDetails.isAccountActive}==false){
          //	  document.getElementById("account_container").style.backgroundColor = "#FF0000"  
          // }
    	  google.charts.load('current', {packages: ['corechart', 'bar', 'table', 'map', 'line']});
    	  //google.charts.setOnLoadCallback(drawTable);
    	  //google.charts.setOnLoadCallback(drawMap);
    	  google.charts.setOnLoadCallback(drawRevenueVsSentiment);
    	  google.charts.setOnLoadCallback(drawRevenueByCategoryChart);
    	  google.charts.setOnLoadCallback(drawRevenueBySubCategoryChart);
      }

    </script>
</head>
<body onload="loadCharts()">
	<div class="header">
		<div id="brandingLayout">
                <a class="brandingContent" href="CustomerOverview?requestType=customerOverview">
                    <img src="images/hortonworks-logo-new.png" width="200px"/>
                    <span class="brandTitle" data-i18n="BRAND_TITLE"></span>
                </a>
		</div>
	</div>
	
	<div id="bodyContainer" class="body_container">
		<div id="top_div" class="section_container">
			<div class="top_section">
				<div id="details" class="profile_container">
	
				</div>
				<div id="map1" class="map_container"></div>
			</div>
		</div>
		<div id="charts" class="section_container">
			<div class="charts_section" class="section_container">
				<div id="chart1" class="chart_container"></div>
				<div id="chart2" class="chart_container"></div>
			</div>
		</div>
	<%-- <div id="transactionList" class="transaction_list">
			<div class="transaction_listing">
				<div id="" class="table_header_container">Transaction Id</div>
				<div id="" class="table_header_container">Merchant Type</div>
				<div id="" class="table_header_container">Amount</div>
				<div id="" class="table_header_container">Date</div> 
			</div>
			<c:forEach items="${transactionHistory}" var="transaction">
				<div id="${transaction.transactionId}" class="transaction_listing">
					<div id="" class="table_cell_container">
						<a href="CustomerOverview?requestType=sendFraudNotice&accountNumber=${transaction.accountNumber}&fraudulentTransactionId=${transaction.transactionId}">${transaction.transactionId}</a>
					</div>
					<div id="" class="table_cell_container">
						${transaction.merchantType}
					</div>
					<div id="" class="table_cell_container">
						${transaction.amount}
					</div>
					<div id="" class="table_cell_container">
						${transaction.transactionTimeStamp}
					</div>
				</div>
          	</c:forEach>
		</div> --%>	
		<div id="legitTransaction_table" class="table_container"></div>
		<div id="fraudTransaction_table" class="table_container"></div>
	</div>
</body>
</html>