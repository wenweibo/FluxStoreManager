import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../common/config.dart';
import '../../../../../generated/l10n.dart';
import '../../../../../models/app_model.dart';
import '../../../../../models/entities/sale_stats.dart';

class SaleStatsChart extends StatelessWidget {
  final SaleStats? saleStats;

  const SaleStatsChart({Key? key, this.saleStats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var grossSaleData;
    var earningsData;

    grossSaleData = [
      SaleSeries(S.of(context).week('1'), 0,
          charts.ColorUtil.fromDartColor(Colors.blue)),
      SaleSeries(S.of(context).week('2'), 0,
          charts.ColorUtil.fromDartColor(Colors.blue)),
      SaleSeries(S.of(context).week('3'), 0,
          charts.ColorUtil.fromDartColor(Colors.blue)),
      SaleSeries(S.of(context).week('4'), 0,
          charts.ColorUtil.fromDartColor(Colors.blue)),
      SaleSeries(S.of(context).week('5'), 0,
          charts.ColorUtil.fromDartColor(Colors.blue)),
    ];

    earningsData = [
      SaleSeries(S.of(context).week('1'), 0,
          charts.ColorUtil.fromDartColor(Colors.red)),
      SaleSeries(S.of(context).week('2'), 0,
          charts.ColorUtil.fromDartColor(Colors.red)),
      SaleSeries(S.of(context).week('3'), 0,
          charts.ColorUtil.fromDartColor(Colors.red)),
      SaleSeries(S.of(context).week('4'), 0,
          charts.ColorUtil.fromDartColor(Colors.red)),
      SaleSeries(S.of(context).week('5'), 0,
          charts.ColorUtil.fromDartColor(Colors.red)),
    ];

    if (saleStats != null) {
      grossSaleData = [
        SaleSeries(S.of(context).week('1'), saleStats!.grossSales?.week1 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.blue)),
        SaleSeries(S.of(context).week('2'), saleStats!.grossSales?.week2 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.blue)),
        SaleSeries(S.of(context).week('3'), saleStats!.grossSales?.week3 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.blue)),
        SaleSeries(S.of(context).week('4'), saleStats!.grossSales?.week4 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.blue)),
        SaleSeries(S.of(context).week('5'), saleStats!.grossSales?.week5 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.blue)),
      ];

      earningsData = [
        SaleSeries(S.of(context).week('1'), saleStats!.earnings?.week1 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.red)),
        SaleSeries(S.of(context).week('2'), saleStats!.earnings?.week2 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.red)),
        SaleSeries(S.of(context).week('3'), saleStats!.earnings?.week3 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.red)),
        SaleSeries(S.of(context).week('4'), saleStats!.earnings?.week4 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.red)),
        SaleSeries(S.of(context).week('5'), saleStats!.earnings?.week5 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.red)),
      ];
    }

    final series = <charts.Series<SaleSeries, String>>[
      charts.Series(
        id: 'Gross Sales',
        data: grossSaleData,
        domainFn: (SaleSeries series, _) => series.week,
        measureFn: (SaleSeries series, _) => series.sale,
        colorFn: (SaleSeries series, _) => charts.Color.transparent,
      ),
      charts.Series(
        id: 'Gross Sales',
        data: grossSaleData,
        domainFn: (SaleSeries series, _) => series.week,
        measureFn: (SaleSeries series, _) => series.sale,
        colorFn: (SaleSeries series, _) => series.color,
      ),
      charts.Series(
        id: 'Earnings',
        data: earningsData,
        domainFn: (SaleSeries series, _) => series.week,
        measureFn: (SaleSeries series, _) => series.sale,
        colorFn: (SaleSeries series, _) => series.color,
      ),
      charts.Series(
        id: 'Earnings',
        data: earningsData,
        domainFn: (SaleSeries series, _) => series.week,
        measureFn: (SaleSeries series, _) => series.sale,
        colorFn: (SaleSeries series, _) => charts.Color.transparent,
      ),
    ];

    final model = Provider.of<AppModel>(context, listen: false);

    /// Because chart_flutter does not support Kurdish
    if (unsupportedLanguages.contains(model.langCode)) {
      return Container();
    }
    var defaultCurrency = kAdvanceConfig.defaultCurrency;
    final simpleCurrencyFormatter =
        charts.BasicNumericTickFormatterSpec.fromNumberFormat(
            NumberFormat.compactSimpleCurrency(
                name: defaultCurrency?.symbol ?? '\$',
                decimalDigits: 0,
                locale: model.langCode));

    return Container(
      height: 260,
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9.0),
          color: Colors.white,
          border: Border.all(color: Colors.grey)),
      child: charts.BarChart(
        series,
        animate: true,
        primaryMeasureAxis: charts.NumericAxisSpec(
          tickFormatterSpec: simpleCurrencyFormatter,
        ),
      ),
    );
  }
}
