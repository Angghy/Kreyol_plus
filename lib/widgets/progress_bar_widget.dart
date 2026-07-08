import 'package:flutter/material.dart';

class ProgressBarWidget extends StatelessWidget {
  final double progress;
  final String label;

  const ProgressBarWidget({
    Key? key,
    required this.progress,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress < 0.5
                  ? Colors.orange
                  : progress < 0.8
                      ? Colors.blue.shade400
                      : Colors.green,
            ),
          ),
        ),
      ],
    );
  }
}

