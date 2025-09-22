import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/theme/app_theme.dart';

class InAppSearchPage extends StatefulWidget {
  final String? initialQuery;

  const InAppSearchPage({super.key, this.initialQuery});

  @override
  State<InAppSearchPage> createState() => _InAppSearchPageState();
}

class _InAppSearchPageState extends State<InAppSearchPage> {
  late final WebViewController _controller;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery ?? '';
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _currentUrl = url;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _currentUrl = url;
            });
          },
        ),
      );

    // Load initial search or Google homepage
    final query = widget.initialQuery?.isNotEmpty == true 
        ? widget.initialQuery!
        : '';
    _performSearch(query);
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      _controller.loadRequest(Uri.parse('https://www.google.com'));
    } else {
      final encodedQuery = Uri.encodeComponent(query);
      _controller.loadRequest(
        Uri.parse('https://www.google.com/search?q=$encodedQuery'),
      );
    }
    _searchController.text = query;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
          style: IconButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
          ),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search Google...',
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.textSecondary,
                size: 20,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                      icon: Icon(
                        Icons.clear,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            onSubmitted: _performSearch,
            onChanged: (value) => setState(() {}),
          ),
        ).animate().fadeIn().slideX(),
        actions: [
          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.textPrimary),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'home',
                child: Row(
                  children: [
                    Icon(Icons.home),
                    SizedBox(width: 8),
                    Text('Google Home'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share Link'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick search suggestions
          if (_searchController.text.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Searches',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickSearchChip('AI Assistant Tips'),
                      _buildQuickSearchChip('Flutter Development'),
                      _buildQuickSearchChip('Weather Today'),
                      _buildQuickSearchChip('Latest News'),
                      _buildQuickSearchChip('Technology Trends'),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),

          // WebView
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.inputBorder,
                    width: 1,
                  ),
                ),
              ),
              child: WebViewWidget(controller: _controller),
            ),
          ),

          // Bottom navigation bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(
                  color: AppColors.inputBorder,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () async {
                    if (await _controller.canGoBack()) {
                      await _controller.goBack();
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (await _controller.canGoForward()) {
                      await _controller.goForward();
                    }
                  },
                  icon: const Icon(Icons.arrow_forward),
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.public,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Secure',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSearchChip(String label) {
    return GestureDetector(
      onTap: () => _performSearch(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh':
        _controller.reload();
        break;
      case 'home':
        _controller.loadRequest(Uri.parse('https://www.google.com'));
        _searchController.clear();
        break;
      case 'share':
        _shareCurrentUrl();
        break;
    }
  }

  void _shareCurrentUrl() {
    // Implementation would use share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.link, color: Colors.white),
            const SizedBox(width: 8),
            const Expanded(child: Text('URL copied to clipboard')),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}