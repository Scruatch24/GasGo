// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import 'auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'welcomeToApp',
      subtitle: 'lowestFuelPrices',
      icon: Icons.local_gas_station,
      color: Color(0xFF1E88E5),
    ),
    OnboardingPage(
      title: 'findStations',
      subtitle: 'findNearestStations',
      icon: Icons.map,
      color: Color(0xFF43A047),
    ),
    OnboardingPage(
      title: 'saveMoney',
      subtitle: 'saveMoneyAffordable',
      icon: Icons.savings,
      color: Color(0xFFFF7043),
    ),
    OnboardingPage(
      title: 'forOwners',
      subtitle: 'addYourStation',
      icon: Icons.business,
      color: Color(0xFF8E24AA),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => _navigateToAuth(),
                  child: Text(
                    l10n.skip ?? 'Skip',
                    style: TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(pages[index], l10n);
                },
              ),
            ),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                    (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: currentPage == index
                        ? Color(0xFF1E88E5)
                        : Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  currentPage > 0
                      ? TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                    child: Text(
                      l10n.previous ?? 'Previous',
                      style: TextStyle(
                        color: Color(0xFF757575),
                        fontSize: 16,
                      ),
                    ),
                  )
                      : SizedBox(width: 80),

                  // Next/Get Started button
                  ElevatedButton(
                    onPressed: () {
                      if (currentPage == pages.length - 1) {
                        _navigateToAuth();
                      } else {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      currentPage == pages.length - 1
                          ? (l10n.getStarted ?? 'Get Started')
                          : (l10n.next ?? 'Next'),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: page.color,
            ),
          ),

          SizedBox(height: 32),

          // Title
          Text(
            _getLocalizedText(l10n, page.title),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 16),

          // Subtitle
          Text(
            _getLocalizedText(l10n, page.subtitle),
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF757575),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getLocalizedText(AppLocalizations l10n, String key) {
    switch (key) {
      case 'welcomeToApp':
        return l10n.welcomeToApp ?? 'Welcome to LPG Finder GE';
      case 'lowestFuelPrices':
        return l10n.lowestFuelPrices ?? 'The lowest fuel prices in one space';
      case 'findStations':
        return l10n.findStations ?? 'Find Stations';
      case 'findNearestStations':
        return l10n.findNearestStations ?? 'Find the nearest private gas stations on the map';
      case 'saveMoney':
        return l10n.saveMoney ?? 'Save Money';
      case 'saveMoneyAffordable':
        return l10n.saveMoneyAffordable ?? 'Save money with the most affordable tariffs';
      case 'forOwners':
        return l10n.forOwners ?? 'For Station Owners';
      case 'addYourStation':
        return l10n.addYourStation ?? 'Add your station and attract more customers';
      default:
        return key;
    }
  }

  void _navigateToAuth() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => AuthScreen()),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}