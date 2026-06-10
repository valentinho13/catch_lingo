import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';

import '../app/app_theme.dart';
import '../data/caught_word_storage.dart';
import '../data/detection_service.dart';
import '../data/mock_catch_words.dart';
import '../models/catch_word.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const _storage = CaughtWordStorage();
  static const _sessionGoal = 5;
  final _detectionService = MockDetectionService();

  final Set<String> _collectedWords = {};
  final List<CatchWord> _sessionCaught = [];
  CameraController? _cameraController;
  Timer? _detectionTimer;
  CatchWord? _activeDetection;
  CatchWord? _justCaught;
  bool _justCaughtIsDuplicate = false;
  bool _sessionComplete = false;
  String? _cameraMessage;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _loadCaughtWords();
    _startCamera();
  }

  @override
  void dispose() {
    _detectionTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  void _scheduleNextDetection({Duration delay = const Duration(seconds: 1)}) {
    _detectionTimer?.cancel();

    setState(() {
      _isScanning = true;
      _activeDetection = null;
      _justCaught = null;
    });

    _detectionTimer = Timer(delay, _showNextDetection);
  }

  void _showNextDetection() {
    if (!mounted) {
      return;
    }

    final nextWord = _detectionService.nextDetection();

    setState(() {
      _activeDetection = nextWord;
      _isScanning = false;
    });
  }

  void _scanNext() {
    _scheduleNextDetection(delay: const Duration(milliseconds: 450));
  }

  Future<void> _startCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        _setCameraMessage('No camera found. Showing preview scene.');
        return;
      }

      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _cameraMessage = null;
      });
    } on CameraException catch (error) {
      _setCameraMessage(_messageForCameraException(error));
    } catch (_) {
      _setCameraMessage('Camera is not available. Showing preview scene.');
    }
  }

  void _setCameraMessage(String message) {
    if (!mounted) {
      return;
    }

    setState(() {
      _cameraMessage = message;
    });
  }

  String _messageForCameraException(CameraException error) {
    return switch (error.code) {
      'CameraAccessDenied' ||
      'CameraAccessDeniedWithoutPrompt' ||
      'CameraAccessRestricted' =>
        'Camera access is blocked. Enable it in system settings.',
      _ => 'Camera is not available. Showing preview scene.',
    };
  }

  Future<void> _loadCaughtWords() async {
    final words = await _storage.loadWords();

    if (!mounted) {
      return;
    }

    setState(() {
      _collectedWords.addAll(words.map((word) => word.id));
    });

    _scheduleNextDetection();
  }

  Future<void> _collectWord(CatchWord detectedWord) async {
    final word = detectedWord;
    _detectionTimer?.cancel();
    HapticFeedback.mediumImpact();

    if (_collectedWords.contains(word.id)) {
      final reinforcedWord = await _storage.reinforceWord(word);

      if (!mounted) {
        return;
      }

      setState(() {
        _justCaught = reinforcedWord ?? word;
        _justCaughtIsDuplicate = true;
        _activeDetection = null;
        _isScanning = false;
      });

      _detectionTimer = Timer(const Duration(milliseconds: 1600), _afterReveal);

      return;
    }

    final caughtWord = word.caughtNow();

    setState(() {
      _collectedWords.add(caughtWord.id);
      _sessionCaught.add(caughtWord);
      _justCaught = caughtWord;
      _justCaughtIsDuplicate = false;
      _activeDetection = null;
      _isScanning = false;
    });

    await _storage.saveWord(caughtWord);

    if (!mounted) {
      return;
    }

    if (_sessionCaught.length >= _sessionGoal) {
      _detectionTimer = Timer(
        const Duration(milliseconds: 1700),
        _completeSession,
      );
    } else {
      _detectionTimer = Timer(const Duration(milliseconds: 1600), _afterReveal);
    }
  }

  void _afterReveal() {
    if (!mounted) {
      return;
    }

    _scheduleNextDetection(delay: const Duration(milliseconds: 80));
  }

  void _completeSession() {
    if (!mounted) {
      return;
    }

    _detectionTimer?.cancel();
    HapticFeedback.lightImpact();

    setState(() {
      _sessionComplete = true;
      _justCaught = null;
      _activeDetection = null;
      _isScanning = false;
    });
  }

  void _continueAfterSession() {
    setState(() {
      _sessionComplete = false;
      _sessionCaught.clear();
    });

    _scheduleNextDetection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: _FullscreenDiscoveryLayer(
              words: mockCatchWords,
              collectedWords: _collectedWords,
              activeDetection: _activeDetection,
              isScanning: _isScanning,
              cameraController: _cameraController,
              cameraMessage: _cameraMessage,
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isLandscape =
                    constraints.maxWidth > constraints.maxHeight;
                final panelWidth = isLandscape
                    ? (constraints.maxWidth * 0.36).clamp(300.0, 430.0)
                    : (constraints.maxWidth * 0.90).clamp(300.0, 460.0);

                return Padding(
                  padding: const EdgeInsets.all(CatchLingoSpacing.lg),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: _ExploreTopBar(count: _collectedWords.length),
                      ),
                      Positioned(
                        left: isLandscape
                            ? null
                            : (constraints.maxWidth - panelWidth) / 2,
                        right: isLandscape ? 0 : null,
                        bottom: 0,
                        width: panelWidth,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: constraints.maxHeight - 92,
                          ),
                          child: SingleChildScrollView(
                            reverse: true,
                            physics: const ClampingScrollPhysics(),
                            child: _DetectionBottomPanel(
                              activeDetection: _activeDetection,
                              justCaught: _justCaught,
                              justCaughtIsDuplicate: _justCaughtIsDuplicate,
                              isScanning: _isScanning,
                              onCatch: _collectWord,
                              onScanNext: _scanNext,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_sessionComplete)
            Positioned.fill(
              child: _SessionCompleteOverlay(
                words: _sessionCaught,
                onContinue: _continueAfterSession,
                onExit: () => Navigator.of(context).pop(),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExploreTopBar extends StatelessWidget {
  const _ExploreTopBar({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filled(
          onPressed: () => Navigator.of(context).pop(),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.82),
            foregroundColor: CatchLingoColors.textPrimary,
            minimumSize: const Size.square(40),
            fixedSize: const Size.square(40),
          ),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: CatchLingoSpacing.sm),
        Expanded(
          child: Text(
            'Explore',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: CatchLingoSpacing.sm),
        _TinyCollectionPill(count: count),
      ],
    );
  }
}

class _TinyCollectionPill extends StatelessWidget {
  const _TinyCollectionPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: CatchLingoMotion.state,
      child: Container(
        key: ValueKey(count),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
        ),
        child: Text(
          '$count caught',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: CatchLingoColors.warmGreen,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _FullscreenDiscoveryLayer extends StatelessWidget {
  const _FullscreenDiscoveryLayer({
    required this.words,
    required this.collectedWords,
    required this.activeDetection,
    required this.isScanning,
    required this.cameraController,
    required this.cameraMessage,
  });

  final List<CatchWord> words;
  final Set<String> collectedWords;
  final CatchWord? activeDetection;
  final bool isScanning;
  final CameraController? cameraController;
  final String? cameraMessage;

  @override
  Widget build(BuildContext context) {
    final hasCamera = cameraController?.value.isInitialized ?? false;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasCamera)
          _CameraScenePreview(
            controller: cameraController!,
            borderRadius: BorderRadius.zero,
          )
        else
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE8D5B0),
                  Color(0xFFD4B896),
                  Color(0xFFC8B08A),
                ],
              ),
            ),
            child: _SceneTableSurface(),
          ),
        // Subtle warm edge vignette — lets the world breathe
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.28),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.38),
              ],
              stops: const [0, 0.38, 1],
            ),
          ),
        ),
        if (cameraMessage != null)
          Positioned(
            left: CatchLingoSpacing.lg,
            right: CatchLingoSpacing.lg,
            bottom: CatchLingoSpacing.lg,
            child: _CameraMessage(message: cameraMessage!),
          ),
        for (final word in words.where(
          (word) => activeDetection?.id == word.id,
        ))
          _DetectionMarker(
            word: word,
            isActive: activeDetection?.id == word.id,
            isKnown: collectedWords.contains(word.id),
          ),
      ],
    );
  }
}

class _CameraScenePreview extends StatelessWidget {
  const _CameraScenePreview({
    required this.controller,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(CatchLingoRadius.panel),
    ),
  });

  final CameraController controller;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final previewAspectRatio =
              MediaQuery.orientationOf(context) == Orientation.landscape
              ? controller.value.aspectRatio
              : 1 / controller.value.aspectRatio;
          final panelAspectRatio = constraints.maxWidth / constraints.maxHeight;
          final shouldFitWidth = panelAspectRatio > previewAspectRatio;
          final previewWidth = shouldFitWidth
              ? constraints.maxWidth
              : constraints.maxHeight * previewAspectRatio;
          final previewHeight = shouldFitWidth
              ? constraints.maxWidth / previewAspectRatio
              : constraints.maxHeight;

          return Center(
            child: SizedBox(
              width: previewWidth,
              height: previewHeight,
              child: CameraPreview(controller),
            ),
          );
        },
      ),
    );
  }
}

class _CameraMessage extends StatelessWidget {
  const _CameraMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CatchLingoSpacing.md,
        vertical: CatchLingoSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(CatchLingoRadius.card),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.videocam_off_rounded,
            size: 18,
            color: CatchLingoColors.warmGreen,
          ),
          const SizedBox(width: CatchLingoSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: CatchLingoColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneTableSurface extends StatelessWidget {
  const _SceneTableSurface();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _SceneTableSurfacePainter(
          color: Colors.white.withValues(alpha: 0.18),
          accent: CatchLingoColors.amber.withValues(alpha: 0.14),
        ),
      ),
    );
  }
}

class _SceneTableSurfacePainter extends CustomPainter {
  const _SceneTableSurfacePainter({required this.color, required this.accent});

  final Color color;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final tableRect = Rect.fromCenter(
      center: Offset(size.width * 0.52, size.height * 0.58),
      width: size.width * 0.78,
      height: size.height * 0.48,
    );

    final tablePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withValues(alpha: 0.05), color, accent],
      ).createShader(tableRect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(tableRect, const Radius.circular(42)),
      tablePaint,
    );

    final rimPaint = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(tableRect.deflate(8), const Radius.circular(34)),
      rimPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SceneTableSurfacePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.accent != accent;
  }
}

class _DetectionMarker extends StatelessWidget {
  const _DetectionMarker({
    required this.word,
    required this.isActive,
    required this.isKnown,
  });

  final CatchWord word;
  final bool isActive;
  final bool isKnown;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(word.markerX, word.markerY),
      child: AnimatedContainer(
        duration: CatchLingoMotion.state,
        width: isActive ? 104 : 54,
        height: isActive ? 54 : 48,
        padding: const EdgeInsets.all(CatchLingoSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: isActive ? 0.95 : 0.78),
          borderRadius: BorderRadius.circular(isActive ? 18 : 16),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _markerIconFor(word),
              size: 20,
              color: CatchLingoColors.warmGreen,
            ),
            if (isActive) ...[
              const SizedBox(width: CatchLingoSpacing.sm),
              Flexible(
                child: Text(
                  word.source,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: CatchLingoColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ] else if (isKnown) ...[
              const SizedBox(width: CatchLingoSpacing.xs),
              Icon(
                Icons.check_circle_rounded,
                size: 14,
                color: CatchLingoColors.warmGreen,
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _markerIconFor(CatchWord word) {
    return switch (word.source) {
      'coffee' => Icons.local_cafe_rounded,
      'cup' => Icons.local_drink_rounded,
      'table' => Icons.table_restaurant_rounded,
      'chair' => Icons.chair_rounded,
      _ => Icons.center_focus_strong_rounded,
    };
  }
}

class _DetectionBottomPanel extends StatelessWidget {
  const _DetectionBottomPanel({
    required this.activeDetection,
    required this.justCaught,
    required this.justCaughtIsDuplicate,
    required this.isScanning,
    required this.onCatch,
    required this.onScanNext,
  });

  final CatchWord? activeDetection;
  final CatchWord? justCaught;
  final bool justCaughtIsDuplicate;
  final bool isScanning;
  final ValueChanged<CatchWord> onCatch;
  final VoidCallback onScanNext;

  @override
  Widget build(BuildContext context) {
    final word = activeDetection;
    final caught = justCaught;

    final Widget child;
    final String key;

    if (caught != null) {
      key = 'reveal-${caught.id}-$justCaughtIsDuplicate';
      child = _CatchRevealCard(
        word: caught,
        isDuplicate: justCaughtIsDuplicate,
      );
    } else if (word == null) {
      key = 'scan-$isScanning';
      child = _ScanningStatus(isEmpty: !isScanning);
    } else {
      key = 'detect-${word.id}';
      child = _DetectedWordCard(
        word: word,
        onCatch: onCatch,
        onScanNext: onScanNext,
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
            child: child,
          ),
        );
      },
      child: ClipRRect(
        key: ValueKey(key),
        borderRadius: BorderRadius.circular(CatchLingoRadius.card),
        child: child,
      ),
    );
  }
}

class _DetectedWordCard extends StatelessWidget {
  const _DetectedWordCard({
    required this.word,
    required this.onCatch,
    required this.onScanNext,
  });

  final CatchWord word;
  final ValueChanged<CatchWord> onCatch;
  final VoidCallback onScanNext;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Something here',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: CatchLingoColors.warmGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _DetectionCategoryPill(label: word.category),
          ],
        ),
        const SizedBox(height: CatchLingoSpacing.xs),
        Text(
          word.source,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: CatchLingoColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Catch it to discover the word',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: CatchLingoColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: CatchLingoSpacing.sm),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => onCatch(word),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  backgroundColor: CatchLingoColors.warmGreen,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.catching_pokemon_rounded),
                label: const Text('Catch'),
              ),
            ),
            const SizedBox(width: CatchLingoSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onScanNext,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Look around'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  foregroundColor: CatchLingoColors.textPrimary,
                  side: BorderSide(
                    color: CatchLingoColors.textPrimary.withValues(alpha: 0.22),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(CatchLingoSpacing.md),
      decoration: BoxDecoration(
        color: CatchLingoColors.warmSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: content,
    );
  }
}

class _DetectionCategoryPill extends StatelessWidget {
  const _DetectionCategoryPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: CatchLingoColors.warmGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: CatchLingoColors.warmGreen,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ScanningStatus extends StatelessWidget {
  const _ScanningStatus({required this.isEmpty});

  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: CatchLingoSpacing.lg,
          vertical: CatchLingoSpacing.md,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, color: CatchLingoColors.amber),
            const SizedBox(width: CatchLingoSpacing.md),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEmpty ? 'Keep an eye out…' : 'Looking around',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: CatchLingoColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isEmpty
                        ? 'Something to discover nearby'
                        : 'There might be something here',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: CatchLingoColors.textMuted,
                      fontWeight: FontWeight.w500,
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
}

class _CatchRevealCard extends StatelessWidget {
  const _CatchRevealCard({required this.word, required this.isDuplicate});

  final CatchWord word;
  final bool isDuplicate;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 460),
      curve: Curves.easeOutBack,
      builder: (context, t, child) {
        return Transform.scale(
          scale: 0.82 + 0.18 * t.clamp(0.0, 1.0),
          child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(CatchLingoSpacing.lg),
        decoration: BoxDecoration(
          color: CatchLingoColors.warmSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  isDuplicate
                      ? Icons.visibility_rounded
                      : Icons.auto_awesome_rounded,
                  color: CatchLingoColors.amber,
                  size: 20,
                ),
                const SizedBox(width: CatchLingoSpacing.sm),
                Text(
                  isDuplicate ? 'Spotted again' : 'Found it',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: CatchLingoColors.amber,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: CatchLingoSpacing.sm),
            Text(
              word.translation,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: CatchLingoColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isDuplicate
                  ? '${word.source} · spotted ${word.seenCount} times'
                  : word.source,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CatchLingoColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionCompleteOverlay extends StatelessWidget {
  const _SessionCompleteOverlay({
    required this.words,
    required this.onContinue,
    required this.onExit,
  });

  final List<CatchWord> words;
  final VoidCallback onContinue;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.55),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(CatchLingoSpacing.lg),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) {
          return Opacity(
            opacity: t.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, 16 * (1 - t)),
              child: child,
            ),
          );
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(CatchLingoSpacing.xl),
            decoration: BoxDecoration(
              color: CatchLingoColors.warmSurface,
              borderRadius: BorderRadius.circular(CatchLingoRadius.panel),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 36,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: CatchLingoColors.amber,
                  size: 32,
                ),
                const SizedBox(height: CatchLingoSpacing.md),
                Text(
                  'Good finds',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: CatchLingoColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: CatchLingoSpacing.xs),
                Text(
                  'You caught ${words.length} words from this moment.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CatchLingoColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: CatchLingoSpacing.lg),
                ...words.map(
                  (word) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: CatchLingoSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            word.source,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: CatchLingoColors.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: CatchLingoColors.amber,
                        ),
                        const SizedBox(width: CatchLingoSpacing.sm),
                        Expanded(
                          child: Text(
                            word.translation,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: CatchLingoColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: CatchLingoSpacing.lg),
                FilledButton(
                  onPressed: onContinue,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: CatchLingoColors.warmGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Keep exploring'),
                ),
                const SizedBox(height: CatchLingoSpacing.sm),
                TextButton(
                  onPressed: onExit,
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    foregroundColor: CatchLingoColors.textMuted,
                  ),
                  child: const Text('Done for now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
