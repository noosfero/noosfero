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

  function legend(chart, chartIndex) {
    var legendItems = chart.chart.legend.legendItems;
    var html = '';
    for (item in legendItems) {
      var legend_text = '<div style="display: flex; margin: unset; margin-right: 5px; margin-bottom: 5px;"><div style="width: 10px; height: 10px; background: ${legendItems[item].fillStyle}; margin-right: 5px;"></div><span style="width: 130px; display: inline-block; font-size: 11px;">' + legendItems[item].text + '</span></div>'
      html += legend_text;
    }
    document.getElementById("legend-" + chartIndex).innerHTML = html;
    document.querySelector("#chart-" + chartIndex).setAttribute("style", "width: 50%");
  }

  $( document ).ready(function() {
    if(Chart.defaults.global.plugins.datalabels) {
      Chart.defaults.global.plugins.datalabels.color = "white";
      Chart.defaults.global.plugins.datalabels.formatter = function(value, context) {
        var total = 0;
        for (var i in context.dataset.data) {
          total += context.dataset.data[i];
        }
        var tooltipPercentage = Math.round((value / total) * 100);

        return tooltipPercentage + '%';
      };

      Chart.defaults.global.plugins.datalabels.display = function (context) {
        return context.dataset.data[context.dataIndex] !== 0;
      }

      const charts = Chartkick.charts;
      const chartPrefix = "chart-";
      var chartIndex = 1;

      while (true){
        var chart = charts[chartPrefix + chartIndex];
        legend(chart, chartIndex);
        if (typeof chart == "undefined")
          break;

        var graph = chart.getChartObject();
        if (graph.config.type == 'pie' || graph.config.type == 'bar') {
          chart.redraw();
        }
        chartIndex += 1;
      }
    }
  });

})();
