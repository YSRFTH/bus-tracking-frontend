import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/bus.dart';

class BusDetailsSheet extends StatelessWidget {
  final Bus bus;

  const BusDetailsSheet({super.key, required this.bus});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              red: 0,
              green: 0,
              blue: 0,
              alpha: 26,
            ),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            bus.routeName,
            style: Theme.of(context).textTheme.headlineSmall,
          ).animate().fadeIn().slideX(),
          const SizedBox(height: 8),
          Text(
            'Bus Number: ${bus.busNumber}',
            style: Theme.of(context).textTheme.titleMedium,
          ).animate().fadeIn().slideX(delay: 100.ms),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            Icons.location_on,
            'Next Stop',
            bus.nextStop,
            delay: 200,
          ),
          _buildInfoRow(
            context,
            Icons.timer,
            'ETA',
            '${bus.etaMinutes} minutes',
            delay: 300,
          ),
          _buildInfoRow(
            context,
            Icons.straighten,
            'Distance',
            '${(bus.distanceToNextStop / 1000).toStringAsFixed(1)} km',
            delay: 400,
          ),
          _buildInfoRow(
            context,
            Icons.speed,
            'Speed',
            '${bus.speed.toStringAsFixed(1)} km/h',
            delay: 500,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    required int delay,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideX(delay: delay.ms);
  }
}
