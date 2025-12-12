import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:phonix_scanner/secondary_box.dart';
import 'package:phonix_scanner/colors.dart';

class AppStatusBox extends StatefulWidget {
  const AppStatusBox({super.key});

  @override
  State<AppStatusBox> createState() => _AppStatusBoxState();
}

class _AppStatusBoxState extends State<AppStatusBox> {
  late List<ConnectivityResult> _connectionState;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    final initialConnectivity = await Connectivity().checkConnectivity();
    setState(() {
      _connectionState = initialConnectivity;
    });

    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      setState(() {
        _connectionState = results;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final connected = _connectionState.isNotEmpty && !_connectionState.contains(ConnectivityResult.none);
    return SecondaryBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                connected ? Icons.wifi : Icons.wifi_off,
                size: 20,
                color: connected ? AppColors.white : AppColors.error,
              ),
              const SizedBox(width: 8),
              Text(
                connected ? 'Connected' : 'No Connection',
                style: TextStyle(color: connected ? AppColors.black : AppColors.error),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_outlined, size: 20, color: AppColors.white),
              SizedBox(width: 8),
              Text('Secure', style: TextStyle(color: AppColors.black)),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time, size: 20, color: AppColors.white),
              SizedBox(width: 8),
              Text('-', style: TextStyle(color: AppColors.black)),
            ],
          ),
        ],
      ),
    );
  }
}