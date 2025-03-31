import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:naukolatek/functions/pie_patcher.dart';

class Pie extends StatefulWidget {
  final double size;
  final double totalExpenses;
  final double budget;

  const Pie(this.size,
      {required this.totalExpenses, required this.budget, Key? key})
      : super(key: key);

  @override
  State<Pie> createState() => _PieState();
}

class _PieState extends State<Pie> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;
  double _prevSize = 0.0;

  @override
  void initState() {
    super.initState();
    _prevSize = widget.size;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _sizeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _rotationAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Start animation when widget is built
    _animationController.forward();
  }

  @override
  void didUpdateWidget(Pie oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only animate when size changes significantly (fixes jitter)
    if ((oldWidget.size - widget.size).abs() > 1.0) {
      _prevSize = widget.size;
      if (widget.size > oldWidget.size) {
        // Growing animation
        _animationController.forward(from: _animationController.value * 0.8);
      } else if (widget.size < oldWidget.size) {
        // Shrinking animation - less dramatic to avoid visual disruption
        _animationController
            .animateTo(0.7, duration: const Duration(milliseconds: 150))
            .then((_) => _animationController.forward());
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return LayoutBuilder(builder: (context, constraints) {
          // Ensure we're using the correct size constraints
          final maxSize = math.min(widget.size,
              math.min(constraints.maxWidth, constraints.maxHeight));
          final actualSize = maxSize * _sizeAnimation.value;

          // Avoid extremely small charts
          if (actualSize < 20) {
            return const SizedBox();
          }

          return Center(
            child: Container(
              width: actualSize,
              height: actualSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple
                        .withOpacity(0.15 * _opacityAnimation.value),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Transform.rotate(
                angle: _rotationAnimation.value * math.pi,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pie chart background
                      Container(
                        width: actualSize,
                        height: actualSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromARGB(255, 12, 0, 34)
                              .withOpacity(0.4),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1.5,
                          ),
                        ),
                      ),

                      // Pie chart
                      CustomPaint(
                        size: Size(actualSize, actualSize),
                        painter: PieChartPainter(
                          totalExpenses: widget.totalExpenses,
                          budget: widget.budget,
                          height: actualSize,
                          animationValue: _animationController.value,
                        ),
                      ),

                      // Outer ring for more refined look
                      Container(
                        width: actualSize,
                        height: actualSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                            width: 2,
                          ),
                        ),
                      ),

                      // Center content - percentage display
                      if (actualSize > 60) _buildCenterContent(actualSize),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildCenterContent(double chartSize) {
    // Calculate percentage - protect against division by zero
    double percentageUsed = 0.0;
    if (widget.budget > 0) {
      percentageUsed =
          math.min((widget.totalExpenses / widget.budget) * 100, 100);
    }

    final isOverBudget = widget.totalExpenses > widget.budget;
    final centerSize = chartSize * 0.5;

    // Ensure the center content is appropriately sized
    final fontSize = math.max(chartSize * 0.12, 16.0);
    final smallFontSize = math.max(chartSize * 0.05, 10.0);

    // Define gradient colors based on budget status
    List<Color> gradientColors = isOverBudget
        ? [Colors.red.shade400, Colors.red.shade700]
        : [Colors.deepPurple.shade300, Colors.purple.shade700];

    return Container(
      width: centerSize,
      height: centerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color.fromARGB(255, 12, 0, 34).withOpacity(0.8),
            const Color.fromARGB(255, 20, 0, 50).withOpacity(0.8),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isOverBudget
                ? Colors.red.withOpacity(0.2)
                : Colors.deepPurple.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate if text would wrap
            final textSpan = TextSpan(
              text: '${percentageUsed.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );

            final textPainter = TextPainter(
              text: textSpan,
              textDirection: TextDirection.ltr,
              maxLines: 1,
            );

            textPainter.layout(maxWidth: constraints.maxWidth);

            // Check if text would overflow or need to wrap
            final wouldTextWrap = textPainter.didExceedMaxLines ||
                textPainter.width > constraints.maxWidth;

            // If text would wrap, return empty container (text fades away)
            if (wouldTextWrap) {
              return SizedBox();
            }

            // Otherwise show the text normally
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: gradientColors,
                    ).createShader(bounds);
                  },
                  child: Text(
                    '${percentageUsed.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                ),
                SizedBox(height: 4),
              ],
            );
          },
        ),
      ),
    );
  }
}
