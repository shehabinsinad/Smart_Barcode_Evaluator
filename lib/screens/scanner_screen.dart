import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';
import 'package:food_scanner_app/services/auth_service.dart';
import 'package:food_scanner_app/theme/app_colors.dart';
import 'package:food_scanner_app/theme/app_theme.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/landing');
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() => _isProcessing = true);

    // Haptic feedback
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }

    // Navigate to results with slight delay for feedback
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (mounted) {
      Navigator.pushNamed(context, '/results', arguments: barcode.rawValue);
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Scan Product', style: theme.textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera View
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Dark overlay with cutout
          CustomPaint(
            size: Size(size.width, size.height),
            painter: _ScannerOverlayPainter(
              animation: _pulseController,
              isProcessing: _isProcessing,
            ),
          ),

          // Instructions and UI
          Column(
            children: [
              const Spacer(flex: 2),

              // Scanning area with animated corners
              Center(
                child: SizedBox(
                  width: size.width * 0.7,
                  height: size.width * 0.7,
                  child: Stack(
                    children: [
                      // Top-left corner
                      Positioned(
                        top: 0,
                        left: 0,
                        child: _buildCorner(
                          Colors.white,
                          [BorderSide.none, const BorderSide(color: Colors.white, width: 4)],
                          [const BorderSide(color: Colors.white, width: 4), BorderSide.none],
                        ),
                      ),
                      // Top-right corner
                      Positioned(
                        top: 0,
                        right: 0,
                        child: _buildCorner(
                          Colors.white,
                          [const BorderSide(color: Colors.white, width: 4), BorderSide.none],
                          [BorderSide.none, const BorderSide(color: Colors.white, width: 4)],
                        ),
                      ),
                      // Bottom-left corner
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: _buildCorner(
                          Colors.white,
                          [BorderSide.none, const BorderSide(color: Colors.white, width: 4)],
                          [const BorderSide(color: Colors.white, width: 4), BorderSide.none],
                        ),
                      ),
                      // Bottom-right corner
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: _buildCorner(
                          Colors.white,
                          [const BorderSide(color: Colors.white, width: 4), BorderSide.none],
                          [BorderSide.none, const BorderSide(color: Colors.white, width: 4)],
                        ),
                      ),

                      // Grid guides
                      if (!_isProcessing)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _GridPainter(),
                          ),
                        ),

                      // Scanning line animation
                      if (!_isProcessing)
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Positioned(
                              top: _pulseController.value * (size.width * 0.7 - 4),
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.primary.withValues(alpha: 0.8),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spaceLG),

              // Instructions
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLG),
                padding: const EdgeInsets.all(AppTheme.spaceMD),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    if (_isProcessing)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Processing...',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          const Icon(
                            Icons.qr_code_scanner_rounded,
                            color: AppColors.primary,
                            size: 40,
                          ).animate(onPlay: (controller) => controller.repeat())
                              .shimmer(duration: 2000.ms, color: AppColors.primaryLight.withValues(alpha: 0.5)),
                          const SizedBox(height: 8),
                          Text(
                            'Position barcode within frame',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Auto-scan enabled',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),

              const Spacer(flex: 2),

              // Flashlight toggle
              Container(
                margin: const EdgeInsets.only(bottom: AppTheme.spaceLG),
                child: IconButton(
                  onPressed: () => _controller.toggleTorch(),
                  icon: const Icon(
                    Icons.flashlight_on_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.7),
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.8, 0.8)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(Color color, List<BorderSide> topBorders, List<BorderSide> leftBorders) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final opacity = _isProcessing ? 0.3 : (0.7 + (_pulseController.value * 0.3));
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border(
              top: topBorders[0],
              right: topBorders[1],
              bottom: leftBorders[0],
              left: leftBorders[1],
            ),
          ),
          foregroundDecoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: color.withValues(alpha: opacity),
                width: 4,
              ),
              right: BorderSide(
                color: topBorders[1] != BorderSide.none
                    ? color.withValues(alpha: opacity)
                    : Colors.transparent,
                width: 4,
              ),
              bottom: BorderSide(
                color: leftBorders[0] != BorderSide.none
                    ? color.withValues(alpha: opacity)
                    : Colors.transparent,
                width: 4,
              ),
              left: BorderSide(
                color: leftBorders[1] != BorderSide.none
                    ? color.withValues(alpha: opacity)
                    : Colors.transparent,
                width: 4,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isProcessing;

  _ScannerOverlayPainter({
    required this.animation,
    required this.isProcessing,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final scanAreaSize = size.width * 0.7;
    final scanAreaLeft = (size.width - scanAreaSize) / 2;
    final scanAreaTop = (size.height - scanAreaSize) / 2;

    final scanRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(scanAreaLeft, scanAreaTop, scanAreaSize, scanAreaSize),
      const Radius.circular(16),
    );

    final outerRect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(outerRect),
        Path()..addRRect(scanRect),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.isProcessing != isProcessing;
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Horizontal lines
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 2 / 3),
      Offset(size.width, size.height * 2 / 3),
      paint,
    );

    // Vertical lines
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 2 / 3, 0),
      Offset(size.width * 2 / 3, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
