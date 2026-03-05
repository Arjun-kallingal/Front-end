import 'package:flutter/material.dart';
import 'package:front_end/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class GoalDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> goal;

  const GoalDetailsScreen({
    super.key,
    required this.goal,
  });

  @override
  State<GoalDetailsScreen> createState() =>
      _GoalDetailsScreenState();
}

class _GoalDetailsScreenState
    extends State<GoalDetailsScreen> {

  late double saved;
  late double target;
  late DateTime deadline;

  final TextEditingController _amountController =
      TextEditingController();

  DateTime? selectedDate;

  late List<Map<String, dynamic>> history;

  @override
  void initState() {
    super.initState();

    saved = widget.goal["saved"] ?? 0.0;
    target = widget.goal["target"] ?? 0.0;
    deadline = widget.goal["deadline"];

    // 🔥 Load existing history if available
    history =
        widget.goal["history"] != null
            ? List<Map<String, dynamic>>.from(
                widget.goal["history"])
            : [];
  }

  /// =============================
  /// PICK DATE
  /// =============================
  Future<void> _pickDate() async {
    DateTime? pickedDate =
        await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  /// =============================
  /// ADD AMOUNT
  /// =============================
  void _addAmount() {
    double? amount =
        double.tryParse(_amountController.text);

    if (amount != null && amount > 0) {
      setState(() {
        saved += amount;

        history.add({
          "amount": amount,
          "date": selectedDate ?? DateTime.now(),
        });

        // 🔥 Update main goal map
        widget.goal["saved"] = saved;
        widget.goal["history"] = history;
      });

      _amountController.clear();
      selectedDate = null;
    }
  }

  /// =============================
  /// EDIT TRANSACTION
  /// =============================
  void _editTransaction(int index) {
    TextEditingController editController =
        TextEditingController(
            text: history[index]["amount"]
                .toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Transaction"),
        content: TextField(
          controller: editController,
          keyboardType:
              TextInputType.number,
          decoration:
              const InputDecoration(
            hintText: "Enter new amount",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              double? newAmount =
                  double.tryParse(
                      editController.text);

              if (newAmount != null &&
                  newAmount > 0) {
                setState(() {
                  saved -=
                      history[index]["amount"];
                  saved += newAmount;

                  history[index]["amount"] =
                      newAmount;

                  // 🔥 Update main goal
                  widget.goal["saved"] =
                      saved;
                  widget.goal["history"] =
                      history;
                });
              }

              Navigator.pop(context);
            },
            child:
                const Text("Update"),
          ),
        ],
      ),
    );
  }

  /// =============================
  /// DELETE TRANSACTION
  /// =============================
  void _deleteTransaction(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:
            const Text("Delete Transaction"),
        content: const Text(
            "Amount will be removed from this goal."),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red),
            onPressed: () {
              setState(() {
                saved -= history[index]
                    ["amount"];

                history.removeAt(index);

                // 🔥 Update main goal
                widget.goal["saved"] =
                    saved;
                widget.goal["history"] =
                    history;
              });

              Navigator.pop(context);
            },
            child:
                const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress =
        target == 0
            ? 0
            : (saved / target)
                .clamp(0.0, 1.0);

    int daysLeft =
        deadline.difference(
                DateTime.now())
            .inDays;

    return Scaffold(
      backgroundColor:
          AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [

            /// =============================
            /// HEADER CONTAINER
            /// =============================
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(20),
              decoration:
                  const BoxDecoration(
                gradient:
                    LinearGradient(
                  colors: [
                    AppColors
                        .headerGradientStart,
                    AppColors
                        .headerGradientEnd,
                  ],
                ),
                borderRadius:
                    BorderRadius.only(
                  bottomLeft:
                      Radius.circular(
                          25),
                  bottomRight:
                      Radius.circular(
                          25),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        Navigator.pop(
                            context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color:
                          Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.goal[
                          "title"],
                      textAlign:
                          TextAlign
                              .center,
                      style:
                          const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight
                                .bold,
                        color:
                            Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                      width: 48),
                ],
              ),
            ),

            /// =============================
            /// BODY
            /// =============================
            Expanded(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets
                        .all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [

                    const Text(
                        "Currently Saved"),
                    const SizedBox(
                        height: 5),

                    Text(
                      "\$${saved.toStringAsFixed(0)}",
                      style:
                          TextStyle(
                        fontSize: 28,
                        fontWeight:
                            FontWeight
                                .bold,
                        color: widget
                                .goal[
                            "color"],
                      ),
                    ),

                    const SizedBox(
                        height: 20),

                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor:
                          Colors.grey
                              .shade300,
                      valueColor:
                          AlwaysStoppedAnimation(
                              widget.goal[
                                  "color"]),
                    ),

                    const SizedBox(
                        height: 10),

                    Text(
                        "Target: \$${target.toStringAsFixed(0)}"),

                    Text(
                      daysLeft >= 0
                          ? "$daysLeft days remaining"
                          : "Goal expired",
                      style: TextStyle(
                        color:
                            daysLeft >= 0
                                ? Colors
                                    .green
                                : Colors
                                    .red,
                      ),
                    ),

                    const SizedBox(
                        height: 30),

                    /// ADD AMOUNT
                    const Text(
                      "Add Amount",
                      style: TextStyle(
                          fontWeight:
                              FontWeight
                                  .bold),
                    ),

                    const SizedBox(
                        height: 10),

                    TextField(
                      controller:
                          _amountController,
                      keyboardType:
                          TextInputType
                              .number,
                      decoration:
                          const InputDecoration(
                        hintText:
                            "Enter amount",
                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(
                        height: 10),

                    Row(
                      children: [
                        Expanded(
                          child:
                              OutlinedButton(
                            onPressed:
                                _pickDate,
                            child: Text(
                              selectedDate ==
                                      null
                                  ? "Pick Date"
                                  : DateFormat(
                                          "dd MMM yyyy")
                                      .format(
                                          selectedDate!),
                            ),
                          ),
                        ),
                        const SizedBox(
                            width: 10),
                        Expanded(
                          child:
                              ElevatedButton(
                            onPressed:
                                _addAmount,
                            child:
                                const Text(
                                    "Add"),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                        height: 30),

                    if (history
                        .isNotEmpty)
                      const Text(
                        "Transaction History",
                        style: TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold),
                      ),

                    const SizedBox(
                        height: 10),

                    ...List.generate(
                        history.length,
                        (index) {
                      var item =
                          history[
                              index];

                      return Card(
                        child:
                            ListTile(
                          title: Text(
                              "+ \$${item["amount"]}"),
                          subtitle: Text(
                            DateFormat(
                                    "dd MMM yyyy - hh:mm a")
                                .format(
                                    item["date"]),
                          ),
                          trailing:
                              PopupMenuButton<
                                  String>(
                            onSelected:
                                (value) {
                              if (value ==
                                  "edit") {
                                _editTransaction(
                                    index);
                              } else if (value ==
                                  "delete") {
                                _deleteTransaction(
                                    index);
                              }
                            },
                            itemBuilder:
                                (context) =>
                                    const [
                              PopupMenuItem(
                                value:
                                    "edit",
                                child:
                                    Text(
                                        "Edit"),
                              ),
                              PopupMenuItem(
                                value:
                                    "delete",
                                child:
                                    Text(
                                        "Delete"),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}