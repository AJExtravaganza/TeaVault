/// Example of a combo time series chart with two series rendered as lines, and
/// a third rendered as points along the top line with a different color.
///
/// This example demonstrates a method for drawing points along a line using a
/// different color from the main series color. The line renderer supports
/// drawing points with the "includePoints" option, but those points will share
/// the same color as the line.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class DateTimeComboLinePointChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  DateTimeComboLinePointChart(this.seriesList, {this.animate});

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory DateTimeComboLinePointChart.withSampleData() {
    return new DateTimeComboLinePointChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      // Configure the default renderer as a line renderer. This will be used
      // for any series that does not define a rendererIdKey.
      //
      // This is the default configuration, but is shown here for  illustration.
      defaultRenderer: new charts.LineRendererConfig(),
      // Custom renderer configuration for the point series.
      customSeriesRenderers: [
        new charts.PointRendererConfig(
            // ID used to link series to this renderer.
            customRendererId: 'customPoint')
      ],
      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TimeSeriesValue, DateTime>> _createSampleData() {
    final temperatureDataUpper = [
      new TimeSeriesValue(new DateTime(2017, 9, 19), 25),
      new TimeSeriesValue(new DateTime(2017, 9, 26), 25.5),
      new TimeSeriesValue(new DateTime(2017, 10, 3), 25.3),
      new TimeSeriesValue(new DateTime(2017, 10, 10), 28),
    ];

    final temperatureDataLower = [
      new TimeSeriesValue(new DateTime(2017, 9, 19), 24),
      new TimeSeriesValue(new DateTime(2017, 9, 26), 23.5),
      new TimeSeriesValue(new DateTime(2017, 10, 3), 23.3),
      new TimeSeriesValue(new DateTime(2017, 10, 10), 22),
    ];

    final humidityDataUpper = [
      new TimeSeriesValue(new DateTime(2017, 9, 19), 69),
      new TimeSeriesValue(new DateTime(2017, 9, 26), 72),
      new TimeSeriesValue(new DateTime(2017, 10, 3), 70),
      new TimeSeriesValue(new DateTime(2017, 10, 10), 70),
    ];

    final humidityDataLower = [
      new TimeSeriesValue(new DateTime(2017, 9, 19), 65),
      new TimeSeriesValue(new DateTime(2017, 9, 26), 64),
      new TimeSeriesValue(new DateTime(2017, 10, 3), 67),
      new TimeSeriesValue(new DateTime(2017, 10, 10), 69),
    ];

    return [
      new charts.Series<TimeSeriesValue, DateTime>(
        id: 'Upper Temperature',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (TimeSeriesValue sales, _) => sales.time,
        measureFn: (TimeSeriesValue sales, _) => sales.value,
        data: temperatureDataUpper,
      ),
      new charts.Series<TimeSeriesValue, DateTime>(
        id: 'Lower Temperature',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (TimeSeriesValue temperature, _) => temperature.time,
        measureFn: (TimeSeriesValue temperature, _) => temperature.value,
        data: temperatureDataLower,
      ),
      new charts.Series<TimeSeriesValue, DateTime>(
        id: 'Upper Humidity',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesValue humidity, _) => humidity.time,
        measureFn: (TimeSeriesValue humidity, _) => humidity.value,
        data: humidityDataUpper,
      ),
      new charts.Series<TimeSeriesValue, DateTime>(
        id: 'Lower Humidity',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesValue humidity, _) => humidity.time,
        measureFn: (TimeSeriesValue humidity, _) => humidity.value,
        data: humidityDataLower,
      ),
    ];
  }
}

/// Sample data type
class TimeSeriesValue {
  final DateTime time;
  final double value;

  TimeSeriesValue(this.time, this.value);
}
