//= require Chart.bundle
//= require chartkick

$( document ).ready(function() {
	const charts = Chartkick.charts;
	const chartPrefix = "chart-";
	var chartIndex = 1;

	while (true){
		var chart = charts[chartPrefix + chartIndex];
		if (typeof chart == "undefined")
			break;

		var graph = chart.getChartObject();
		if (graph.config.type == 'pie'){
			graph.options.tooltips.callbacks.label = function(tooltipItem, data) {
				var allData = data.datasets[tooltipItem.datasetIndex].data;
				var tooltipLabel = data.labels[tooltipItem.index];
				var tooltipData = allData[tooltipItem.index];
				var total = 0; for (var i in allData) {
					total += allData[i];
				}
				var tooltipPercentage = Math.round((tooltipData / total) * 100);
				return tooltipLabel + ': ' + tooltipData + ' (' + tooltipPercentage + '%)';
			};
			graph.update();
			break;
		}

		chartIndex += 1;
	}
});
