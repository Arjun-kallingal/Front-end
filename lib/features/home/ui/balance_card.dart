import 'package:flutter/material.dart';
import 'package:front_end/core/constants/app_colors.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isBalanceVisible = true;
  String _selectedType = 'All';

  final List<String> _walletTypes = [
    'All',
    'Cash',
    'Account',
    'Add Account',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(30),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.primary,
            width: 3,
          ),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Wallet + Premium Selector
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  _buildPremiumSelector(context),
                ],
              ),

              /// 👁 Eye Icon
              IconButton(
                icon: Icon(
                  _isBalanceVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                onPressed: () {
                  setState(() {
                    _isBalanceVisible = !_isBalanceVisible;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// 🔹 Available Balance
          Text(
            'Available Balance',
            style: textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _isBalanceVisible ? '₹ 25,450' : '••••••••',
            style: textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 15),

          /// 🔹 Reserved Amount
          Text(
            'Reserved Amount',
            style: textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _isBalanceVisible ? '₹ 1,550' : '••••••••',
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.savingsPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 15),

          /// 🔹 Total Balance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                _isBalanceVisible ? '₹ 27,000' : '••••••••',
                style: textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 💎 Modern Fintech Popup Selector
  Widget _buildPremiumSelector(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (details) async {
        final selected = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy + 8,
            details.globalPosition.dx,
            details.globalPosition.dy,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 12,
          color: theme.colorScheme.surface,
          items: _walletTypes.map((type) {
            final isSelected = type == _selectedType;

            return PopupMenuItem<String>(
              value: type,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 10),
                child: Row(
                  children: [
                    if (isSelected)
                      Icon(
                        Icons.check,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    if (isSelected) const SizedBox(width: 8),
                    Text(
                      type,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );

        if (selected != null) {
          setState(() {
            _selectedType = selected;
          });
        }
      },
      child: Row(
        children: [
          Text(
            _selectedType,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ],
      ),
    );
  }
}