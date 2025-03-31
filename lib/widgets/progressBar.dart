import 'package:flutter/material.dart';
import 'package:naukolatek/styles/style.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({Key? key, required this.count, required this.goal})
      : super(key: key);

  final double count;
  final double goal;

  @override
  Widget build(BuildContext context) {
    final double _barWidth = MediaQuery.of(context).size.width * 0.6;

    // Oblicz szerokość paska, zabezpieczając przed przekroczeniem zakresu
    final double progressWidth = (_barWidth * count / goal).clamp(0, _barWidth);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Column(
          children: [
            Stack(
              children: <Widget>[
                // Tło paska postępu
                Container(
                  margin: const EdgeInsets.only(right: 20.0),
                  height: 25.0,
                  width: _barWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: const Color.fromRGBO(234, 234, 234, 1.0),
                  ),
                ),
                // Pasek postępu (ograniczony do max szerokości)
                Container(
                  height: 25.0,
                  width: progressWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    gradient: const LinearGradient(
                      colors: <Color>[
                        Color.fromRGBO(185, 235, 255, 1.0),
                        Color.fromRGBO(145, 224, 255, 1.0),
                        Color.fromRGBO(85, 206, 255, 1.0),
                        Colors.lightBlueAccent,
                      ],
                      stops: [0.25, 0.5, 0.75, 1.0],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Tekst pod paskiem postępu
            Text(
              'Wydałeś już: ${(count / goal * 100).toStringAsFixed(1)}% z ${goal}zł',
              style: h2,
            ),
          ],
        ),
      ],
    );
  }
}
