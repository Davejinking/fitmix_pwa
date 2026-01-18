import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class GoalCard extends StatelessWidget {
  final String title;
  final double percent;

  const GoalCard({super.key, required this.title, required this.percent});

  @override
  Widget build(BuildContext context) {
    final percentText = '${(percent * 100).toStringAsFixed(1)}%';

    return Card(
      elevation: AppConstants.cardElevation,
      color: Colors.blue.shade900,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppConstants.smallPadding),
                  LinearProgressIndicator(
                    value: percent, 
                    minHeight: AppConstants.progressBarHeight, 
                    color: Colors.lightBlue
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(percentText, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
