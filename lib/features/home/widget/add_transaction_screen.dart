import 'package:flutter/material.dart';
import 'package:front_end/core/constants/app_colors.dart';

class TransactionHeader extends StatelessWidget {
  final bool isExpense;
  final VoidCallback onIncomeTap;
  final VoidCallback onExpenseTap;

  const TransactionHeader({
    super.key,
    required this.isExpense,
    required this.onIncomeTap,
    required this.onExpenseTap,
  });

  @override
  Widget build(BuildContext context) {
   

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
       
         gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 98, 14, 14),
                    Color.fromARGB(255, 184, 20, 20),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Back + Title
          Row(
            children: [
             IconButton(
                  onPressed:  () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              const SizedBox(width: 16),
              Text(
                isExpense ? "Add Expense" : "Add Income",
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          /// Toggle Buttons
          Container(
            height: 55,
            decoration: BoxDecoration(
              color: AppColors.filterSelectedBg,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [

                /// Income Button
                Expanded(
                  child: GestureDetector(
                    onTap: onIncomeTap,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: !isExpense
                            ? AppColors.textPrimary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        "Income",
                        style: TextStyle(
                          color: !isExpense
                              ? AppColors.incomeAmount
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),

                /// Expense Button
                Expanded(
                  child: GestureDetector(
                    onTap: onExpenseTap,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isExpense
                            ? AppColors.textPrimary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        "Expense",
                        style: TextStyle(
                          color: isExpense
                              ? AppColors.expenseAmount
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w900,
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
    );
  }
}