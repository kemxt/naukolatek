import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naukolatek/models/CategoryConstants.dart';
import 'package:naukolatek/state/categorySum.dart';
import 'package:naukolatek/styles/style.dart';
import 'package:naukolatek/widgets/progressBar.dart';

class SnapCarousel extends ConsumerStatefulWidget {
  const SnapCarousel(this.mapData, {Key? key}) : super(key: key);
  final Map<String, dynamic> mapData;
  @override
  ConsumerState<SnapCarousel> createState() => _SnapCarouselState();
}

class _SnapCarouselState extends ConsumerState<SnapCarousel>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: 0,
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.93, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    // Auto-scroll timer
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < categoryConstants.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, double> goals = {
      'Zdrowie': (widget.mapData['health']),
      'Jedzenie': (widget.mapData['food']),
      'Zainteresowania': (widget.mapData['hobby']),
      'Edukacja': (widget.mapData['education']),
      'Praca': widget.mapData['work'],
      'Inne': (widget.mapData['other'])
    };
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: categoryConstants.length,
            itemBuilder: (context, index) {
              final category = categoryConstants[index];
              return _buildCategoryCard(
                title: category,
                gradientColors: categoryColors[category] ??
                    [Colors.grey[800]!, Colors.grey[600]!],
                count: ref.watch(categorySumProvider(category)),
                goal: goals[category] ?? 200,
                isCurrentPage: _currentPage == index,
              );
            },
          ),
        ),
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required List<Color> gradientColors,
    required double count,
    required double goal,
    required bool isCurrentPage,
  }) {
    // Trigger animation when page changes
    if (isCurrentPage) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: isCurrentPage ? _animation.value : 0.9,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: Colors.white.withOpacity(0.1),
                highlightColor: Colors.transparent,
                onTap: () => _onCategoryTap(title),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title == 'Jedzenie' ? 'Zywność' : title,
                            style: h2.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                          _getCategoryIcon(title),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ProgressBar(
                        count: count,
                        goal: goal,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${count.toStringAsFixed(0)} zł',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Cel: ${goal.toStringAsFixed(0)} zł',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          categoryConstants.length,
          (index) => _buildDot(index),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final bool isActive = _currentPage == index;
    final Color dotColor =
        isActive ? Colors.white : Colors.white.withOpacity(0.3);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: isActive ? 8 : 6,
      width: isActive ? 24 : 6,
      decoration: BoxDecoration(
        color: dotColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _onCategoryTap(String category) {
    print("$category tapped");
    // You could add navigation to category detail page here
  }

  Widget _getCategoryIcon(String category) {
    IconData iconData;

    switch (category) {
      case 'Zdrowie':
        iconData = Icons.favorite;
        break;
      case 'Jedzenie':
        iconData = Icons.restaurant;
        break;
      case 'Zainteresowania':
        iconData = Icons.sports_esports;
        break;
      case 'Edukacja':
        iconData = Icons.school;
        break;
      case 'Praca':
        iconData = Icons.work;
        break;
      case 'Inne':
      default:
        iconData = Icons.category;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  // Your color and goal maps
  final Map<String, List<Color>> categoryColors = {
    'Zdrowie': [Colors.green.shade600, Colors.green.shade400],
    'Jedzenie': [Colors.teal.shade600, Colors.teal.shade400],
    'Zainteresowania': [Colors.blue.shade600, Colors.blue.shade400],
    'Edukacja': [Colors.purple.shade600, Colors.purple.shade400],
    'Praca': [Colors.indigo.shade600, Colors.indigo.shade400],
    'Inne': [Colors.orange.shade600, Colors.orange.shade400],
  };
}
