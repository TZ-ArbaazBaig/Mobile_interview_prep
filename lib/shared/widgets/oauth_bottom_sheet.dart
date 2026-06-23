import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';

class OAuthBottomSheet extends StatefulWidget {
  final Uri url;

  const OAuthBottomSheet({super.key, required this.url});

  @override
  State<OAuthBottomSheet> createState() => _OAuthBottomSheetState();
}

class _OAuthBottomSheetState extends State<OAuthBottomSheet> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();

    final String userAgent = Platform.isAndroid
        ? 'Mozilla/5.0 (Linux; Android 13; SM-S901B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36'
        : 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // Use platform-specific user agent to bypass Google Sign-In WebView blocks
      // and prevent keyboard/focus lockups on the password field on Android.
      ..setUserAgent(userAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress / 100.0;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Web resource error in Google OAuth: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint("Google OAuth navigation request: ${request.url}");
            if (request.url.startsWith('interviewprep://')) {
              final uri = Uri.parse(request.url);
              
              // IMPORTANT: Capture authProvider BEFORE popping the bottom sheet,
              // because this context becomes invalid after pop()
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              
              // Pop the bottom sheet first so control returns to the screen
              Navigator.of(context).pop();
              
              // Execute redirection flow after the frame completes (bottom sheet dismissed)
              WidgetsBinding.instance.addPostFrameCallback((_) {
                authProvider.handleOAuthRedirect(uri);
              });
              
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // Bottom Sheet height: 85% (keyboard closed) or 95% (keyboard open) of remaining height
    final double sheetHeight = (MediaQuery.of(context).size.height - keyboardHeight) * (keyboardHeight > 0 ? 0.95 : 0.85);

    return PopScope(
      canPop: keyboardHeight == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboardHeight),
        child: Container(
          height: sheetHeight,
        decoration: const BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        child: Column(
          children: [
            // Drag handle and Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sign in with Google',
                          style: AppTextStyles.h3(color: AppColors.textPrimary),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                            size: 24.0,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Loading Progress Bar
            if (_isLoading)
              LinearProgressIndicator(
                value: _loadingProgress > 0 ? _loadingProgress : null,
                backgroundColor: AppColors.bgTertiary,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.violet),
                minHeight: 2.0,
              )
            else
              const SizedBox(height: 2.0),

            // WebView Widget
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24.0),
                  bottomRight: Radius.circular(24.0),
                ),
                child: WebViewWidget(controller: _controller),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}
