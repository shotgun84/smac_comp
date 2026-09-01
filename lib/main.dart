import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMAC - S24 Ultra Preview',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const S24UltraFrame(),
    );
  }
}

/// Simulates running on Samsung Galaxy S24 Ultra
/// Real specs: 6.8" Dynamic LTPO AMOLED 2X, 1440 x 3120 (19.5:9, 505 ppi)
/// Physical: 162.3 x 79 x 8.6 mm, titanium frame, Gorilla Armor
/// Logical viewport on device: ~412 x 892 dp (@3.5x), we use 412x915 inc. system UI
class S24UltraFrame extends StatelessWidget {
  const S24UltraFrame({super.key});

  static const double _logicalWidth = 412;
  static const double _logicalHeight = 915; // 3120/1440*412 ≈ 893 + system bars
  static const String _specs = 'Galaxy S24 Ultra • 6.8" 1440×3120 • 19.5:9 • 505 ppi • 162.3×79×8.6 mm';

  @override
  Widget build(BuildContext context) {
    // On mobile (real device) just show the app directly without frame
    if (!kIsWeb) {
      return const _PhoneContent();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Fix for "BOTTOM OVERFLOWED BY X PIXELS":
          // Previous code used Transform.scale which paints scaled but keeps
          // the original 915px layout size. On a 700px tall viewport the
          // Center still tries to lay out 995px (phone + labels) and Flutter
          // reports overflow. Using ConstrainedBox + FittedBox gives the
          // child bounded constraints so it scales to fit; SingleChildScrollView
          // inside would give unbounded height and break scaleDown, so we avoid it.
          return Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: _logicalWidth,
                      maxHeight: constraints.maxHeight - 32,
                    ),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: _logicalWidth,
                        height: _logicalHeight + 80,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.phone_android, size: 14, color: Colors.white70),
                                  SizedBox(width: 6),
                                  Text(_specs,
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 11, letterSpacing: 0.2)),
                                ],
                              ),
                            ),
                            Container(
                              width: _logicalWidth,
                              height: _logicalHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black54, blurRadius: 40, offset: Offset(0, 20)),
                                  BoxShadow(
                                      color: Colors.black38, blurRadius: 12, offset: Offset(0, 4)),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(32)),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF8A8D93),
                                          Color(0xFF5A5D64),
                                          Color(0xFF9EA1A8),
                                          Color(0xFF6B6E75)
                                        ],
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(5.5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(27),
                                      ),
                                      padding: const EdgeInsets.all(2.2),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(25),
                                        child: const _PhoneContent(),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: -2,
                                    top: 110,
                                    child: Container(
                                      width: 4,
                                      height: 68,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF7A7D84),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: -2,
                                    top: 195,
                                    child: Container(
                                      width: 4,
                                      height: 92,
                                      decoration: BoxDecoration(
                                          color: const Color(0xFF7A7D84),
                                          borderRadius: BorderRadius.circular(2)),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 6,
                                    right: 38,
                                    child: Container(
                                      width: 22,
                                      height: 4,
                                      decoration: BoxDecoration(
                                          color: const Color(0xFF3A3D44),
                                          borderRadius: BorderRadius.circular(2)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text('Logical 412×915 dp • Physical 1440×3120 px @3.5× • 19.5:9',
                                style:
                                    TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Only show corner badge when there is enough space, prevents overlap on small viewports (e.g. 800x600)
              if (constraints.maxWidth > 900 && constraints.maxHeight > 750)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text('162.3 × 79 × 8.6 mm • 232g • Gorilla Armor',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// The actual app content that runs INSIDE the S24 Ultra screen
/// This is what you'd see on the real device
class _PhoneContent extends StatelessWidget {
  const _PhoneContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // Simulated status bar (S24 Ultra punch-hole)
      body: Column(
        children: [
          // Status bar with punch hole
          Container(
            height: 32,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('9:41', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                    Row(
                      children: [
                        const Icon(Icons.signal_cellular_4_bar, size: 14, color: Colors.black87),
                        const SizedBox(width: 4),
                        const Icon(Icons.wifi, size: 14, color: Colors.black87),
                        const SizedBox(width: 4),
                        Container(
                          width: 22, height: 11,
                          decoration: BoxDecoration(border: Border.all(color: Colors.black38, width: 1), borderRadius: BorderRadius.circular(3)),
                          child: Container(margin: const EdgeInsets.all(1.5), decoration: BoxDecoration(color: const Color(0xFF34C759), borderRadius: BorderRadius.circular(1.5))),
                        ),
                      ],
                    ),
                  ],
                ),
                // Punch hole camera - center top (S24 Ultra)
                Container(
                  width: 14, height: 14,
                  decoration: BoxDecoration(
                    color: Colors.black, shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1A1A1A), width: 1.2),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 4)],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(2.5),
                    decoration: const BoxDecoration(color: Color(0xFF0F172A), shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
          // App bar
          Container(
            height: 56,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Text('My App', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1A1C1E))),
                const Spacer(),
                Icon(Icons.more_vert, color: Colors.black.withValues(alpha: 0.6), size: 20),
              ],
            ),
          ),
          Container(height: 1, color: const Color(0xFFE8EAED)),
          // Main content - your Hello World centered in 6.8" space
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF8F9FA), Color(0xFFEFF1F3)]),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.waving_hand, size: 48, color: Color(0xFF6750A4)),
                  SizedBox(height: 16),
                  Text('Hello World!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF1A1C1E), letterSpacing: -0.5)),
                  SizedBox(height: 8),
                  Text('Running on Galaxy S24 Ultra', style: TextStyle(fontSize: 13, color: Color(0xFF5F6368))),
                  SizedBox(height: 4),
                  Text('412 × 915 dp • 1440 × 3120 px', style: TextStyle(fontSize: 11, color: Color(0xFF80868B))),
                  SizedBox(height: 24),
                  _DeviceInfoChip(),
                ],
              ),
            ),
          ),
          // Gesture navigation bar (Android)
          Container(
            height: 22, color: Colors.white,
            alignment: Alignment.center,
            child: Container(width: 108, height: 4, decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(2))),
          ),
        ],
      ),
    );
  }
}

class _DeviceInfoChip extends StatelessWidget {
  const _DeviceInfoChip();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EAED)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.phone_iphone, size: 14, color: Color(0xFF6750A4)),
          SizedBox(width: 6),
          Text('SM-S928B • 6.8" AMOLED 120Hz • 2600 nits', style: TextStyle(fontSize: 11, color: Color(0xFF5F6368), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
