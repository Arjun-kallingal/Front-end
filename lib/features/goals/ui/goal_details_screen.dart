import 'package:flutter/material.dart';
import '../data/goal_model.dart';

class GoalDetailsScreen extends StatefulWidget {
  final GoalModel goal; // 👈 Fixed: Type is now GoalModel

  const GoalDetailsScreen({Key? key, required this.goal}) : super(key: key);

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(widget.goal.title)),
      body: Center(
        child: Text(
          "Target: ₹${widget.goal.targetAmount}",
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}