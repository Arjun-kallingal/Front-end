import 'package:flutter/material.dart';
import 'package:front_end/core/constants/app_colors.dart';



class AddTransactionScreen extends StatefulWidget {
  final bool isExpense;

  const AddTransactionScreen({
    super.key,
    required this.isExpense,
  });

  @override
  State<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState
    extends State<AddTransactionScreen> {

  late bool isExpense;

  @override
  void initState() {
    super.initState();
    isExpense = widget.isExpense;
  }

  @override
  Widget build(BuildContext context) {

    final Color mainColor =
        isExpense ? AppColors.expenseAmount : AppColors.primaryRed;

    final Color darkColor =
        isExpense ? AppColors.primaryRedDark : AppColors.primaryRed;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Column(
        children: [

          // 🔴🟢 Header
          Container(
            padding: const EdgeInsets.only(
              top: 60,
              left: 20,
              right: 20,
              bottom: 30,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [mainColor, darkColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // 🔙 Back + Title
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: CircleAvatar(
                        backgroundColor:
                            AppColors.profileAvatarBg,
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      isExpense
                          ? "Add Income"
                          : "Add Expense",
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 🔄 Toggle
                Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: AppColors.filterSelectedBg,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [

                      // Expense
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isExpense = true;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isExpense
                                  ? AppColors.textPrimary
                                  : const Color.fromARGB(228, 183, 7, 7),
                              borderRadius:
                                  BorderRadius.circular(15),
                            ),
                            child: Text(
                              "Income",
                              style: TextStyle(
                                color: isExpense
                                    ? AppColors.incomeAmount
                                    : AppColors.textSecondary,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Income
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isExpense = false;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: !isExpense
                                  ? AppColors.textPrimary
                                  : const Color.fromARGB(242, 213, 6, 6),
                              borderRadius:
                                  BorderRadius.circular(15),
                            ),
                            child: Text(
                              "Expense",
                              style: TextStyle(
                                color: !isExpense
                                    ? AppColors.expenseAmount
                                    : AppColors.textSecondary,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // 👇 Body Placeholder
          const Text(
            "Transaction Form Here",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}