import 'package:flutter/material.dart';

class ClaimView extends StatefulWidget {
  const ClaimView({super.key});

  @override
  State<ClaimView> createState() => _ClaimViewState();
}

class _ClaimViewState extends State<ClaimView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Claim View')),
      body: Center(child: Text('Claim View')),
    );
  }
}
