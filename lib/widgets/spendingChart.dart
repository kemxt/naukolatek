import 'package:flutter/material.dart';
import 'package:naukolatek/styles/style.dart';

Widget buildSpendingChart(double dynamicHeight) {
  // Poprawiono typ parametru i usunięto print
  double aspectRatio = dynamicHeight > 0 ? dynamicHeight * 2 : 1;

  final List<Map<String, dynamic>> spendingData = [
    {'month': 'Sty', 'amount': 1200.0},
    {'month': 'Lut', 'amount': 1000.0},
    {'month': 'Mar', 'amount': 1350.0},
    {'month': 'Kwi', 'amount': 1100.0},
    {'month': 'Maj', 'amount': 1250.0},
    {'month': 'Cze', 'amount': 1450.0},
  ];

  return Container(
    margin: EdgeInsets.symmetric(horizontal: 30, vertical: 60),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [
        Colors.white.withOpacity(0.05),
        Colors.lightGreen.withOpacity(0.2)
      ]),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Wykres',
                style: h2.copyWith(color: Colors.white),
              ),
              Icon(
                Icons.show_chart,
                color: Colors.blue[400],
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.white.withOpacity(0.1),
          indent: 16,
          endIndent: 16,
        ),
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: CustomPaint(
              painter: SpendingChartPainter(spendingData),
            ),
          ),
        ),
      ],
    ),
  );
}

class SpendingChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  SpendingChartPainter(this.data);
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Find max and min values
    final double maxAmount =
        data.map((e) => e['amount']).reduce((a, b) => a > b ? a : b);
    final double minAmount =
        data.map((e) => e['amount']).reduce((a, b) => a < b ? a : b);

    // Paints
    final Paint linePaint = Paint()
      ..color = Colors.blue[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final Paint fillPaint = Paint()
      ..color = Colors.blue[400]!.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final Path linePath = Path();
    final Path fillPath = Path();

    // Calculate points
    final List<Offset> points = data.asMap().entries.map((entry) {
      final int index = entry.key;
      final Map<String, dynamic> item = entry.value;

      final double x = (index / (data.length - 1)) * width;
      final double y = height -
          ((item['amount'] - minAmount) / (maxAmount - minAmount)) * height;

      return Offset(x, y);
    }).toList();

    // Create line path
    linePath.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    // Create fill path
    fillPath.addPath(linePath, Offset.zero);
    fillPath.lineTo(width, height);
    fillPath.lineTo(0, height);
    fillPath.close();

    // Draw fill
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    canvas.drawPath(linePath, linePaint);

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 5.0, Paint()..color = Colors.white);
    }

    // Draw grid lines
    final Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Vertical grid lines
    for (int i = 0; i < data.length; i++) {
      final double x = (i / (data.length - 1)) * width;
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }

    // Horizontal grid lines
    for (int i = 1; i < 4; i++) {
      final double y = height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
