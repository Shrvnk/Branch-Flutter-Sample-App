import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

void main() async {
  // 1. Initialize Flutter and the Branch SDK
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterBranchSdk.init(enableLogging: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const BranchLandingPage(),
    );
  }
}

class BranchLandingPage extends StatefulWidget {
  const BranchLandingPage({super.key});

  @override
  State<BranchLandingPage> createState() => _BranchLandingPageState();
}

class _BranchLandingPageState extends State<BranchLandingPage> {
  StreamSubscription<Map>? _branchSubscription;
  String _displayData = "Waiting for a Branch link click...";

  @override
  void initState() {
    super.initState();
    // 2. Start the session listener with a slight delay to ensure readiness
    Future.delayed(const Duration(milliseconds: 750), () {
      _initDeepLinkListener();
    });
  }

  void _initDeepLinkListener() {
    // 3. Listen specifically for deep link session data
    _branchSubscription = FlutterBranchSdk.listSession().listen(
      (data) {
        debugPrint('Branch Link Data: $data');
        if (mounted) {
          setState(() {
            // Check if a link was actually clicked
            if (data.containsKey('+clicked_branch_link') && data['+clicked_branch_link'] == true) {
              _displayData = _formatData(data);
            } else {
              _displayData = "App opened normally (No link clicked).";
            }
          });
        }
      },
      onError: (error) {
        if (mounted) setState(() => _displayData = "Error: $error");
      },
    );
  }

  // Helper to make the JSON data more readable on screen
  String _formatData(Map data) {
    return data.entries.map((e) => "${e.key}: ${e.value}").join("\n");
  }

  @override
  void dispose() {
    _branchSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Branch Deep Link Monitor"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.link, size: 64, color: Colors.deepPurple),
              const SizedBox(height: 16),
              const Text(
                "Link Payload:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: Text(
                  _displayData,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}