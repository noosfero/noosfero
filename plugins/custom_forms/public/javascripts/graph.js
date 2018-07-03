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

function legend(chart) {
  var legendItems = chart.chart.legend.legendItems;
  let html = ``;
  for (item in legendItems) {
    var legend_text = `<div style="display: flex; margin: unset; margin-right: 5px; margin-bottom: 5px;"><div style="width: 10px; height: 10px; background: ${legendItems[item].fillStyle}; margin-right: 5px;"></div><span style="width: 130px; display: inline-block; font-size: 11px;">${legendItems[item].text} </span></div>`
    html += legend_text;
  }
  document.getElementById("legend").innerHTML = html;
  document.querySelector("#chart-1").setAttribute("style", "width: 50%");
}

$( document ).ready(function() {
  const charts = Chartkick.charts;
  const chartPrefix = "chart-";
  var chartIndex = 1;

  while (true){
    var chart = charts[chartPrefix + chartIndex];
    legend(chart);
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

        var tooltipPercentage = Math.round((tooltipData / total) * 100);
        return `${tooltipLabel}: ${tooltipData} (${tooltipPercentage}%}`;
      };
      graph.update();
    }
    chartIndex += 1;
  }
});

})();
