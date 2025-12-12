import 'package:flutter/material.dart';
import 'package:phonix_scanner/colors.dart';

class EventDataBox extends StatelessWidget {
  const EventDataBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.white80,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppColors.white10,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today_outlined, size: 22.0, color: AppColors.eventIcon,),
                const SizedBox(height: 8.0),
                const Text('-', style: TextStyle(fontSize: 14.0)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on_outlined, size: 22.0, color: AppColors.eventIcon,),
                const SizedBox(height: 8.0),
                const Text('Venue', style: TextStyle(fontSize: 14.0)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_outline_outlined, size: 22.0, color: AppColors.eventIcon,),
                const SizedBox(height: 8.0),
                const Text('-', style: TextStyle(fontSize: 14.0)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}