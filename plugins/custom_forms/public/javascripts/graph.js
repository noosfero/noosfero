//= require Chart.bundle
//= require chartkick

(function() {

function summaryFor(chartId, label) {
  var summaries = Chartkick.charts['chart-' + chartId].options['summary'];
  if (!summaries) {
    return '';
  }

  var summary = summaries[label];
  if (summary && summary.offline != 0) {
    return ' - Online: ' + summary.online + '%, Offline: ' +
           summary.offline + '%';
  } else {
    return '';
  }
}

$( document ).ready(function() {
  const charts = Chartkick.charts;
  const chartPrefix = "chart-";
  var chartIndex = 1;

  while (true){
    var chart = charts[chartPrefix + chartIndex];
    if (typeof chart == "undefined")
      break;

    var graph = chart.getChartObject();
    if (graph.config.type == 'pie' || graph.config.type == 'bar') {
      graph.options.tooltips.callbacks.label = function(tooltipItem, data) {
        var allData = data.datasets[tooltipItem.datasetIndex].data;
        var tooltipLabel = data.labels[tooltipItem.index];
        var tooltipData = allData[tooltipItem.index];
        var total = 0; for (var i in allData) {
          total += allData[i];
        }

        var summary = summaryFor(this._chart.id + 1, tooltipLabel);
        var tooltipPercentage = Math.round((tooltipData / total) * 100);
        return tooltipLabel + ': ' + tooltipData +
               ' (' + tooltipPercentage + '%)' + summary;
      };
      graph.update();
    }
    chartIndex += 1;
  }
});

})();
