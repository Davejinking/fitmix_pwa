import 'package:flutter/material.dart';

/// Analytics Detail Screen - Deep Dive into Performance Data
/// Placeholder for detailed charts, history, and trends
class AnalyticsDetailScreen extends StatelessWidget {
  const AnalyticsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFFFF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ANALYTICS',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: const Color(0xFF3D5AFE).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'DETAILED ANALYTICS',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Coming Soon',
              style: TextStyle(
                color: const Color(0xFFFFFFFF).withValues(alpha: 0.5),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Deep dive into your performance metrics,\nhistorical trends, and detailed graphs.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.6),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
