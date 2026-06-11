import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';

import '../app/app_theme.dart';
import '../data/caught_word_storage.dart';
import '../data/detection_service.dart';
import '../data/mock_catch_words.dart';
import '../models/catch_word.dart';
import '../widgets/word_visuals.dart';

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

      _detectionTimer = Timer(const Duration(milliseconds: 2100), _afterReveal);

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
        const Duration(milliseconds: 2200),
        _completeSession,
      );
    } else {
      _detectionTimer = Timer(const Duration(milliseconds: 2100), _afterReveal);
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
          if (_justCaught != null && !_sessionComplete)
            Positioned.fill(
              child: _CatchCelebrationOverlay(
                word: _justCaught!,
                isDuplicate: _justCaughtIsDuplicate,
                totalCaught: _collectedWords.length,
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

class _TinyCollectionPill extends StatefulWidget {
  const _TinyCollectionPill({required this.count});

  final int count;

  @override
  State<_TinyCollectionPill> createState() => _TinyCollectionPillState();
}

class _TinyCollectionPillState extends State<_TinyCollectionPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 1.12,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 42,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.12,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 58,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant _TinyCollectionPill oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.count > oldWidget.count) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: AnimatedSwitcher(
        duration: CatchLingoMotion.state,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.24),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey(widget.count),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
            boxShadow: [
              BoxShadow(
                color: CatchLingoColors.warmGreen.withValues(alpha: 0.14),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            '${widget.count} caught',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: CatchLingoColors.warmGreen,
              fontWeight: FontWeight.w700,
            ),
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
              catchWordIcon(word),
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
      child = const SizedBox.shrink();
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

class _CatchCelebrationOverlay extends StatelessWidget {
  const _CatchCelebrationOverlay({
    required this.word,
    required this.isDuplicate,
    required this.totalCaught,
  });

  final CatchWord word;
  final bool isDuplicate;
  final int totalCaught;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 620),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) {
          final clamped = t.clamp(0.0, 1.0);

          return Opacity(
            opacity: clamped,
            child: Transform.translate(
              offset: Offset(0, 18 * (1 - clamped)),
              child: Transform.scale(
                scale: 0.88 + 0.12 * Curves.easeOutBack.transform(clamped),
                child: child,
              ),
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.16),
              ),
            ),
            const _CelebrationSparkles(),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 330),
                child: Padding(
                  padding: const EdgeInsets.all(CatchLingoSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _GentleMotion(
                        scaleAmount: 0.045,
                        yAmount: 3,
                        duration: const Duration(milliseconds: 980),
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: CatchLingoColors.successSurface,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: CatchLingoColors.warmGreen.withValues(
                                  alpha: 0.28,
                                ),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Icon(
                            isDuplicate
                                ? Icons.visibility_rounded
                                : Icons.check_rounded,
                            color: CatchLingoColors.warmGreen,
                            size: 38,
                          ),
                        ),
                      ),
                      const SizedBox(height: CatchLingoSpacing.md),
                      Text(
                        isDuplicate ? 'Spotted again' : 'Found it',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: CatchLingoSpacing.md),
                      _GentleMotion(
                        scaleAmount: 0.012,
                        yAmount: 4,
                        duration: const Duration(milliseconds: 1400),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: CatchLingoSpacing.xl,
                            vertical: CatchLingoSpacing.xxl,
                          ),
                          decoration: BoxDecoration(
                            color: CatchLingoColors.warmSurface,
                            borderRadius: BorderRadius.circular(
                              CatchLingoRadius.panel,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.24),
                                blurRadius: 34,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                word.translation,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.displayMedium
                                    ?.copyWith(
                                      color: CatchLingoColors.warmGreen,
                                      fontWeight: FontWeight.w800,
                                      height: 1,
                                    ),
                              ),
                              const SizedBox(height: CatchLingoSpacing.sm),
                              Text(
                                word.source,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: CatchLingoColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: CatchLingoSpacing.lg),
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: CatchLingoColors.amber.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Icon(
                                  catchWordIcon(word),
                                  color: CatchLingoColors.textPrimary,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: CatchLingoSpacing.lg),
                      if (!isDuplicate)
                        _RewardToken(totalCaught: totalCaught)
                      else
                        _RevisitToken(seenCount: word.seenCount),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GentleMotion extends StatefulWidget {
  const _GentleMotion({
    required this.child,
    this.scaleAmount = 0.02,
    this.yAmount = 4,
    this.duration = const Duration(milliseconds: 1200),
  });

  final Widget child;
  final double scaleAmount;
  final double yAmount;
  final Duration duration;

  @override
  State<_GentleMotion> createState() => _GentleMotionState();
}

class _GentleMotionState extends State<_GentleMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final phase = math.sin(_controller.value * math.pi * 2);
        final scale = 1 + phase * widget.scaleAmount;
        final y = phase * widget.yAmount;

        return Transform.translate(
          offset: Offset(0, y),
          child: Transform.scale(scale: scale, child: child),
        );
      },
    );
  }
}

class _RewardToken extends StatelessWidget {
  const _RewardToken({required this.totalCaught});

  final int totalCaught;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _GentleMotion(
          scaleAmount: 0.055,
          yAmount: 2,
          duration: const Duration(milliseconds: 820),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC75F),
              borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
              boxShadow: [
                BoxShadow(
                  color: CatchLingoColors.amber.withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              '+1',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: CatchLingoColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: CatchLingoSpacing.sm),
        Text(
          '$totalCaught caught total',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RevisitToken extends StatelessWidget {
  const _RevisitToken({required this.seenCount});

  final int seenCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
      ),
      child: Text(
        'Seen $seenCount times',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: CatchLingoColors.warmGreen,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CelebrationSparkles extends StatefulWidget {
  const _CelebrationSparkles();

  @override
  State<_CelebrationSparkles> createState() => _CelebrationSparklesState();
}

class _CelebrationSparklesState extends State<_CelebrationSparkles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1450),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _CelebrationSparklePainter(progress: _controller.value),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _CelebrationSparklePainter extends CustomPainter {
  const _CelebrationSparklePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final particles = <({Offset origin, double size, double drift})>[
      (
        origin: Offset(size.width * 0.18, size.height * 0.24),
        size: 4.6,
        drift: 18,
      ),
      (
        origin: Offset(size.width * 0.78, size.height * 0.20),
        size: 5.2,
        drift: 24,
      ),
      (
        origin: Offset(size.width * 0.14, size.height * 0.58),
        size: 3.8,
        drift: 22,
      ),
      (
        origin: Offset(size.width * 0.83, size.height * 0.55),
        size: 4.4,
        drift: 20,
      ),
      (
        origin: Offset(size.width * 0.32, size.height * 0.72),
        size: 4.0,
        drift: 18,
      ),
      (
        origin: Offset(size.width * 0.67, size.height * 0.76),
        size: 4.8,
        drift: 22,
      ),
      (
        origin: Offset(size.width * 0.48, size.height * 0.18),
        size: 2.8,
        drift: 26,
      ),
      (
        origin: Offset(size.width * 0.90, size.height * 0.35),
        size: 3.4,
        drift: 18,
      ),
      (
        origin: Offset(size.width * 0.08, size.height * 0.38),
        size: 3.0,
        drift: 16,
      ),
      (
        origin: Offset(size.width * 0.74, size.height * 0.66),
        size: 3.2,
        drift: 20,
      ),
    ];

    for (var i = 0; i < particles.length; i++) {
      final particle = particles[i];
      final phase = progress * math.pi * 2 + i * 0.72;
      final orbit = Offset(
        math.cos(phase) * particle.drift,
        math.sin(phase * 1.18) * particle.drift * 0.56,
      );
      final float = Offset(0, -10 * progress);
      final center = particle.origin + orbit + float;
      final pulse = (math.sin(phase * 1.7) + 1) / 2;
      final radius = particle.size + pulse * 3.2;
      final alpha = 0.34 + pulse * 0.44;
      final color = i.isEven
          ? CatchLingoColors.amber
          : CatchLingoColors.successIcon;
      final glowPaint = Paint()..color = color.withValues(alpha: alpha * 0.16);
      final dotPaint = Paint()..color = color.withValues(alpha: alpha);

      canvas.drawCircle(center, radius * 3.2, glowPaint);
      canvas.drawCircle(center, radius, dotPaint);
      _drawSpark(canvas, center, radius * 2.1, color.withValues(alpha: alpha));
    }
  }

  void _drawSpark(Canvas canvas, Offset center, double length, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      center.translate(-length, 0),
      center.translate(length, 0),
      paint,
    );
    canvas.drawLine(
      center.translate(0, -length),
      center.translate(0, length),
      paint,
    );
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 4);
    canvas.drawLine(Offset(-length * 0.55, 0), Offset(length * 0.55, 0), paint);
    canvas.drawLine(Offset(0, -length * 0.55), Offset(0, length * 0.55), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CelebrationSparklePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ignore: unused_element
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
