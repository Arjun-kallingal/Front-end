import 'package:flutter/material.dart';
import 'package:front_end/core/widgets/custom_button.dart';


class CheckEmailScreen extends StatelessWidget {
  final String email;

  const CheckEmailScreen({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// ICON
                  Icon(
                    Icons.mark_email_read_outlined,
                    size: 64,
                    color: colors.primary,
                  ),

                  const SizedBox(height: 20),

                  /// TITLE
                  Text(
                    'Check Your Email',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// SUBTITLE
                  Text(
                    "We've sent password reset instructions to",
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 6),

                  /// EMAIL
                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// CARD
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'Click the link in the email to reset your password. '
                            'The link will expire in 2 minutes.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall,
                          ),

                          const SizedBox(height: 16),

                          /// TRY AGAIN
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Didn't receive the email? ",
                                style: textTheme.bodySmall,
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Try again'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          /// BACK TO SIGN IN (navigation unchanged)
                          CustomButton(
                            text: 'Back to Sign In',
                            onPressed: () {
                              Navigator.popUntil(
                                context,
                                (route) => route.isFirst,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
