import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    /// Define colors properly
    final bgColor = isLight ? Colors.black : Colors.white;
    final textColor = isLight ? Colors.white : Colors.black;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor, // important
          disabledBackgroundColor: Colors.grey,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        child: isLoading
            ? CircularProgressIndicator(
                strokeWidth: 2,
                color: textColor, // ✅ loader matches text color
              )
            : Text(
                text,
                style: TextStyle(
                  color: textColor, // ✅ force correct text color
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}