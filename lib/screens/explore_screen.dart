import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import '../app/app_theme.dart';
import '../data/caught_word_storage.dart';
import '../data/detection_service.dart';
import '../models/catch_word.dart';
import '../services/catch_haptics.dart';
import '../widgets/word_visuals.dart';
import 'review_screen.dart';

/// Where collected words get drawn to: the session counter in the camera view.
const _counterAlignment = Alignment(0, -0.38);

/// How long a noticed word floats before it has been pulled into the counter.
/// Unhurried on purpose: the word appears, bobs for a moment, then gets
/// drawn in slowly enough to watch and enjoy.
const _noticeFlightDuration = Duration(milliseconds: 6500);

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with WidgetsBindingObserver {
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
  bool _isCameraStarting = true;
  bool _isScanning = true;
  int _sessionKnownSeen = 0;

  bool get _hasSessionProgress =>
      _sessionCaught.isNotEmpty || _sessionKnownSeen > 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCaughtWords();
    _startCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _detectionTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _pauseCameraPreview(controller);
        break;
      case AppLifecycleState.resumed:
        _resumeCameraPreview(controller);
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _pauseCameraPreview(CameraController controller) async {
    try {
      if (!controller.value.isPreviewPaused) {
        await controller.pausePreview();
      }
    } on CameraException {
      // Android may already have reclaimed the preview while backgrounding.
    }
  }

  Future<void> _resumeCameraPreview(CameraController controller) async {
    try {
      if (controller.value.isPreviewPaused) {
        await controller.resumePreview();
      }
    } on CameraException {
      if (mounted) {
        _setCameraMessage('Camera paused while you were away. Try it again.');
      }
    }
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

    if (nextWord == null) {
      return;
    }

    setState(() {
      _activeDetection = nextWord;
      _isScanning = false;
    });

    // The camera notices the word, then gathers it in on its own.
    _detectionTimer = Timer(_noticeFlightDuration, () {
      if (mounted) {
        _collectWord(nextWord);
      }
    });
  }

  Future<void> _startCamera() async {
    final previousController = _cameraController;

    setState(() {
      _isCameraStarting = true;
      _cameraMessage = null;
      _cameraController = null;
    });

    await previousController?.dispose();

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
        _isCameraStarting = false;
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
      _isCameraStarting = false;
    });
  }

  String _messageForCameraException(CameraException error) {
    return switch (error.code) {
      'CameraAccessDenied' ||
      'CameraAccessDeniedWithoutPrompt' ||
      'CameraAccessRestricted' =>
        'Camera access is blocked. Allow camera access, then try again.',
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
    unawaited(CatchHaptics.land());

    if (_collectedWords.contains(word.id)) {
      final reinforcedWord = await _storage.reinforceWord(word);

      if (!mounted) {
        return;
      }

      setState(() {
        _justCaught = reinforcedWord ?? word;
        _justCaughtIsDuplicate = true;
        _sessionKnownSeen += 1;
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
    unawaited(CatchHaptics.soft());

    setState(() {
      _sessionComplete = true;
      _justCaught = null;
      _activeDetection = null;
      _isScanning = false;
    });
  }

  void _finishOrExit() {
    if (!_hasSessionProgress || _sessionComplete) {
      Navigator.of(context).pop();
      return;
    }

    _completeSession();
  }

  void _reviewSessionWords() {
    final initialWordId = _sessionCaught.isEmpty
        ? null
        : _sessionCaught.first.id;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ReviewScreen(initialWordId: initialWordId),
      ),
    );
  }

  void _continueAfterSession() {
    setState(() {
      _sessionComplete = false;
      _sessionCaught.clear();
      _sessionKnownSeen = 0;
    });

    _scheduleNextDetection();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasSessionProgress || _sessionComplete,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _finishOrExit();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: _FullscreenDiscoveryLayer(
                cameraController: _cameraController,
                cameraMessage: _cameraMessage,
                isCameraStarting: _isCameraStarting,
                onRetryCamera: _startCamera,
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(CatchLingoSpacing.lg),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: _ExploreTopBar(
                    count: _collectedWords.length,
                    onExit: _finishOrExit,
                  ),
                ),
              ),
            ),
            if (!_sessionComplete)
              SafeArea(
                child: Align(
                  alignment: _counterAlignment,
                  child: _SessionVacuumCounter(
                    count: _sessionCaught.length,
                    goal: _sessionGoal,
                  ),
                ),
              ),
            if (_activeDetection case final noticedWord?)
              SafeArea(
                child: _NoticedWordChip(
                  key: ValueKey('noticed-${noticedWord.id}'),
                  word: noticedWord,
                ),
              ),
            if (_justCaught != null && !_sessionComplete)
              Positioned.fill(
                child: _CaughtWordReveal(
                  word: _justCaught!,
                  isDuplicate: _justCaughtIsDuplicate,
                ),
              ),
            if (_isScanning && _justCaught == null && !_sessionComplete)
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: CatchLingoSpacing.xl,
                    ),
                    child: const _ScanningHint(),
                  ),
                ),
              ),
            if (_sessionComplete)
              Positioned.fill(
                child: _SessionCompleteOverlay(
                  words: _sessionCaught,
                  knownSeen: _sessionKnownSeen,
                  onContinue: _continueAfterSession,
                  onReview: _sessionCaught.isEmpty ? null : _reviewSessionWords,
                  onExit: () => Navigator.of(context).pop(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExploreTopBar extends StatelessWidget {
  const _ExploreTopBar({required this.count, required this.onExit});

  final int count;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filled(
          onPressed: onExit,
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
    required this.cameraController,
    required this.cameraMessage,
    required this.isCameraStarting,
    required this.onRetryCamera,
  });

  final CameraController? cameraController;
  final String? cameraMessage;
  final bool isCameraStarting;
  final VoidCallback onRetryCamera;

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
        if (!hasCamera && isCameraStarting) const _CameraWarmLoading(),
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
            child: _CameraMessage(
              message: cameraMessage!,
              onRetry: onRetryCamera,
            ),
          ),
      ],
    );
  }
}

class _CameraWarmLoading extends StatelessWidget {
  const _CameraWarmLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 228,
        padding: const EdgeInsets.all(CatchLingoSpacing.lg),
        decoration: BoxDecoration(
          color: CatchLingoColors.warmSurface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(CatchLingoRadius.panel),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _CameraLoadingGlyph(),
            const SizedBox(height: CatchLingoSpacing.md),
            Text(
              'Opening your field view',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: CatchLingoColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: CatchLingoSpacing.xs),
            Text(
              'Getting ready to spot words around you.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: CatchLingoColors.textMuted,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraLoadingGlyph extends StatefulWidget {
  const _CameraLoadingGlyph();

  @override
  State<_CameraLoadingGlyph> createState() => _CameraLoadingGlyphState();
}

class _CameraLoadingGlyphState extends State<_CameraLoadingGlyph>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
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
        final pulse = Curves.easeInOut.transform(_controller.value);

        return Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: CatchLingoColors.amber.withValues(
              alpha: 0.12 + pulse * 0.08,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: CatchLingoColors.amber.withValues(
                alpha: 0.18 + pulse * 0.12,
              ),
            ),
          ),
          child: Icon(
            Icons.photo_camera_rounded,
            color: CatchLingoColors.warmGreen.withValues(
              alpha: 0.72 + pulse * 0.22,
            ),
            size: 30,
          ),
        );
      },
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
  const _CameraMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CatchLingoSpacing.md),
      decoration: BoxDecoration(
        color: CatchLingoColors.warmSurface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(CatchLingoRadius.panel),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: CatchLingoColors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.photo_camera_back_rounded,
                  size: 20,
                  color: CatchLingoColors.warmGreen,
                ),
              ),
              const SizedBox(width: CatchLingoSpacing.sm),
              Expanded(
                child: Text(
                  'Camera needs a quick check',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: CatchLingoColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: CatchLingoSpacing.sm),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: CatchLingoColors.textMuted,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
          const SizedBox(height: CatchLingoSpacing.md),
          FilledButton.icon(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: CatchLingoColors.warmGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(44),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try camera again'),
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

class _SessionVacuumCounter extends StatefulWidget {
  const _SessionVacuumCounter({required this.count, required this.goal});

  final int count;
  final int goal;

  @override
  State<_SessionVacuumCounter> createState() => _SessionVacuumCounterState();
}

class _SessionVacuumCounterState extends State<_SessionVacuumCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 1.08,
        ).chain(CurveTween(curve: Curves.easeOutQuart)),
        weight: 34,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.08,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 66,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant _SessionVacuumCounter oldWidget) {
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
    final progress = widget.goal == 0
        ? 0.0
        : (widget.count / widget.goal).clamp(0.0, 1.0);

    return ScaleTransition(
      scale: _scale,
      child: CustomPaint(
        painter: _SessionRingPainter(progress: progress),
        child: Container(
          width: 74,
          height: 74,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: CatchLingoColors.warmSurface.withValues(alpha: 0.86),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.58),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.count}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: CatchLingoColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'collected',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: CatchLingoColors.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionRingPainter extends CustomPainter {
  const _SessionRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) {
      return;
    }

    final progressPaint = Paint()
      ..color = CatchLingoColors.warmGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SessionRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// A noticed word floats up in the scene, then gets gently pulled into the
/// session counter — the vacuum moment of automatic collection.
class _NoticedWordChip extends StatefulWidget {
  const _NoticedWordChip({super.key, required this.word});

  final CatchWord word;

  @override
  State<_NoticedWordChip> createState() => _NoticedWordChipState();
}

class _NoticedWordChipState extends State<_NoticedWordChip>
    with SingleTickerProviderStateMixin {
  /// Point in the animation where the pull toward the counter takes over.
  static const _pullStart = 0.50;

  late final AnimationController _controller;
  var _pullHapticSent = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: _noticeFlightDuration)
          ..addListener(_sendPullHaptic)
          ..forward();
  }

  void _sendPullHaptic() {
    if (!_pullHapticSent && _controller.value >= _pullStart) {
      _pullHapticSent = true;
      unawaited(CatchHaptics.grip());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
    final startAlignment = Alignment(
      word.markerX.clamp(-0.8, 0.8),
      word.markerY.clamp(-0.2, 0.8),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final appear = const Interval(
          0,
          0.18,
          curve: Curves.easeOutBack,
        ).transform(t);
        final settle = const Interval(
          0.16,
          _pullStart,
          curve: Curves.easeInOutSine,
        ).transform(t);
        final charge = const Interval(
          0.18,
          _pullStart,
          curve: Curves.easeInOutCubic,
        ).transform(t);
        final pull = const Interval(
          _pullStart,
          0.99,
          curve: Curves.easeInOutSine,
        ).transform(t);
        final fade = const Interval(
          0.96,
          1,
          curve: Curves.easeInCubic,
        ).transform(t);

        // A gentle bob while the word floats, settling as the pull takes over.
        final bob =
            math.sin((t + 0.05) * math.pi * 3.2) * 4.0 * appear * (1 - pull);
        final rattle = charge * (1 - pull);
        final shimmer = math.sin(t * math.pi * 26) * rattle;
        final wiggleX =
            (math.sin(t * math.pi * 82) * 5.2 +
                math.sin(t * math.pi * 137) * 1.6) *
            rattle;
        final wiggleY = math.cos(t * math.pi * 96) * 2.2 * rattle;
        final rotation = math.sin(t * math.pi * 88) * 0.022 * rattle;

        // The pull drifts slightly sideways, like a current — not a slide.
        final drift =
            math.sin(pull * math.pi) * 0.10 * (startAlignment.x >= 0 ? 1 : -1);
        final liftedStart = Alignment(
          startAlignment.x,
          startAlignment.y - 0.04 * settle,
        );
        final arcPeak = Alignment(
          (startAlignment.x + _counterAlignment.x) / 2 + drift,
          math.min(startAlignment.y, _counterAlignment.y) - 0.18,
        );
        final firstLeg = Alignment.lerp(liftedStart, arcPeak, pull)!;
        final secondLeg = Alignment.lerp(arcPeak, _counterAlignment, pull)!;
        final pulledAlignment = Alignment.lerp(firstLeg, secondLeg, pull)!;
        final alignment = Alignment(
          pulledAlignment.x.clamp(-1.0, 1.0),
          pulledAlignment.y.clamp(-1.0, 1.0),
        );

        // A small anticipation pop as the suction grips, then shrink inward.
        final double pullScale;
        if (pull <= 0.12) {
          pullScale = 1 + 0.08 * Curves.easeOutBack.transform(pull / 0.12);
        } else if (pull <= 0.72) {
          pullScale =
              1.08 - 0.22 * Curves.easeInOut.transform((pull - 0.12) / 0.60);
        } else {
          pullScale =
              0.86 - 0.48 * Curves.easeInCubic.transform((pull - 0.72) / 0.28);
        }
        final chargeScale = 1 + charge * (1 - pull) * 0.085 + shimmer * 0.018;
        final scale = (0.76 + 0.24 * appear) * chargeScale * pullScale;
        final opacity = (appear * (1 - fade)).clamp(0.0, 1.0);
        final auraProgress = math.max(appear, charge);

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _PullParticlesPainter(
                    start: startAlignment,
                    current: alignment,
                    target: _counterAlignment,
                    pull: pull,
                    tick: t,
                  ),
                ),
              ),
            ),
            Align(
              alignment: alignment,
              child: RepaintBoundary(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(wiggleX, bob + wiggleY),
                    child: Transform.rotate(
                      angle: rotation,
                      child: Transform.scale(
                        scale: scale,
                        child: SizedBox(
                          width: 244,
                          height: 150,
                          child: CustomPaint(
                            painter: _CatchAuraPainter(
                              progress: auraProgress,
                              charge: charge,
                              pull: pull,
                            ),
                            child: Center(child: child),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: CatchLingoColors.warmSurface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.60),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              catchWordIcon(widget.word),
              size: 18,
              color: CatchLingoColors.warmGreen,
            ),
            const SizedBox(width: CatchLingoSpacing.sm),
            Text(
              widget.word.source,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: CatchLingoColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatchAuraPainter extends CustomPainter {
  const _CatchAuraPainter({
    required this.progress,
    required this.charge,
    required this.pull,
  });

  final double progress;
  final double charge;
  final double pull;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final visible = (progress * (1 - pull * 0.55)).clamp(0.0, 1.0);
    final charged = charge * (1 - pull);

    if (visible <= 0) {
      return;
    }

    final haloRadius = size.shortestSide * (0.34 + charged * 0.12);
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          CatchLingoColors.amber.withValues(alpha: 0.22 * visible),
          CatchLingoColors.warmGreen.withValues(alpha: 0.12 * visible),
          Colors.transparent,
        ],
        stops: const [0, 0.54, 1],
      ).createShader(Rect.fromCircle(center: center, radius: haloRadius));

    canvas.drawCircle(center, haloRadius, haloPaint);

    final ringPaint = Paint()
      ..color = CatchLingoColors.amber.withValues(alpha: 0.24 * charged)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    if (charged > 0) {
      final ringRect = Rect.fromCenter(
        center: center,
        width: size.width * (0.72 + charged * 0.08),
        height: size.height * (0.54 + charged * 0.12),
      );
      canvas.drawOval(ringRect, ringPaint);
    }

    final sparklePaint = Paint()
      ..color = CatchLingoColors.amber.withValues(alpha: 0.72 * charged)
      ..style = PaintingStyle.fill;
    final greenSparklePaint = Paint()
      ..color = CatchLingoColors.warmGreen.withValues(alpha: 0.38 * charged)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 7; i++) {
      final phase = (charge + i * 0.19) % 1.0;
      final angle = i * 1.73 + phase * math.pi * 0.7;
      final radius = size.shortestSide * (0.27 + 0.20 * phase);
      final offset = Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      final sparkleCenter = center + offset;
      final sparkleSize = (1.8 + 2.4 * (1 - phase)) * charged;

      canvas.drawCircle(
        sparkleCenter,
        sparkleSize,
        i.isEven ? sparklePaint : greenSparklePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CatchAuraPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.charge != charge ||
        oldDelegate.pull != pull;
  }
}

class _PullParticlesPainter extends CustomPainter {
  const _PullParticlesPainter({
    required this.start,
    required this.current,
    required this.target,
    required this.pull,
    required this.tick,
  });

  final Alignment start;
  final Alignment current;
  final Alignment target;
  final double pull;
  final double tick;

  @override
  void paint(Canvas canvas, Size size) {
    if (pull <= 0.02) {
      return;
    }

    final startPoint = _pointForAlignment(size, current);
    final targetPoint = _pointForAlignment(size, target);
    final originPoint = _pointForAlignment(size, start);
    final merge = Curves.easeInOutSine.transform(pull).clamp(0.0, 1.0);
    final streamPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF9FE8B5).withValues(alpha: 0.12 * pull);

    final control = Offset(
      (originPoint.dx + targetPoint.dx) / 2 +
          math.sin(pull * math.pi) * size.width * 0.08,
      math.min(originPoint.dy, targetPoint.dy) - size.height * 0.12,
    );

    final guidePath = Path()
      ..moveTo(startPoint.dx, startPoint.dy)
      ..quadraticBezierTo(
        control.dx,
        control.dy,
        targetPoint.dx,
        targetPoint.dy,
      );

    canvas.drawPath(guidePath, streamPaint);

    for (var i = 0; i < 18; i++) {
      final travel = ((tick * 1.85) + i * 0.075) % 1.0;
      final easedTravel = Curves.easeInOutCubic.transform(travel);
      final streamStart = (pull * 0.28).clamp(0.0, 0.28);
      final localT = (streamStart + easedTravel * (1 - streamStart)).clamp(
        0.0,
        1.0,
      );
      final position = _quadraticPoint(
        startPoint,
        control,
        targetPoint,
        localT,
      );
      final wobbleAngle = i * 1.91 + tick * math.pi * 7;
      final wobble = Offset(
        math.cos(wobbleAngle) * (5.0 + i % 3) * (1 - localT),
        math.sin(wobbleAngle) * (3.5 + i % 2) * (1 - localT),
      );
      final mergeFade = (1 - localT).clamp(0.0, 1.0);
      final alpha = pull * math.sin(travel * math.pi).abs() * 0.72;
      final bubbleRadius =
          (2.2 + (i % 5) * 0.75) *
          (0.55 + mergeFade * 0.75) *
          (1 - pull * localT * 0.34);

      if (alpha <= 0.02 || bubbleRadius <= 0.4) {
        continue;
      }

      final bubbleCenter = position + wobble;
      final bubblePaint = Paint()
        ..shader =
            RadialGradient(
              colors: [
                Colors.white.withValues(alpha: alpha * 0.58),
                const Color(0xFFB8F5C9).withValues(alpha: alpha * 0.78),
                const Color(0xFF6FCF91).withValues(alpha: alpha * 0.28),
              ],
              stops: const [0, 0.56, 1],
            ).createShader(
              Rect.fromCircle(center: bubbleCenter, radius: bubbleRadius * 1.6),
            );

      canvas.drawCircle(bubbleCenter, bubbleRadius, bubblePaint);

      final rimPaint = Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7;
      canvas.drawCircle(bubbleCenter, bubbleRadius, rimPaint);

      final glintPaint = Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.72)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        bubbleCenter.translate(-bubbleRadius * 0.32, -bubbleRadius * 0.36),
        math.max(0.55, bubbleRadius * 0.22),
        glintPaint,
      );
    }

    final absorbPaint = Paint()
      ..color = const Color(0xFFB8F5C9).withValues(alpha: 0.16 * pull)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 + 2.0 * merge;
    canvas.drawCircle(targetPoint, 8 + 14 * merge, absorbPaint);
  }

  Offset _pointForAlignment(Size size, Alignment alignment) {
    return Offset(
      size.width * (alignment.x + 1) / 2,
      size.height * (alignment.y + 1) / 2,
    );
  }

  Offset _quadraticPoint(Offset a, Offset b, Offset c, double t) {
    final oneMinusT = 1 - t;
    return a * oneMinusT * oneMinusT + b * 2 * oneMinusT * t + c * t * t;
  }

  @override
  bool shouldRepaint(covariant _PullParticlesPainter oldDelegate) {
    return oldDelegate.start != start ||
        oldDelegate.current != current ||
        oldDelegate.target != target ||
        oldDelegate.pull != pull ||
        oldDelegate.tick != tick;
  }
}

class _CaughtWordReveal extends StatelessWidget {
  const _CaughtWordReveal({required this.word, required this.isDuplicate});

  final CatchWord word;
  final bool isDuplicate;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: const Alignment(0, 0.10),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 460),
              curve: Curves.easeOutCubic,
              builder: (context, t, child) {
                final clamped = t.clamp(0.0, 1.0);

                return Opacity(
                  opacity: clamped,
                  child: Transform.translate(
                    offset: Offset(0, 14 * (1 - clamped)),
                    child: Transform.scale(
                      scale: 0.9 + 0.1 * Curves.easeOutBack.transform(clamped),
                      child: child,
                    ),
                  ),
                );
              },
              child: Container(
                constraints: const BoxConstraints(maxWidth: 280),
                padding: const EdgeInsets.symmetric(
                  horizontal: CatchLingoSpacing.xl,
                  vertical: CatchLingoSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: CatchLingoColors.warmSurface,
                  borderRadius: BorderRadius.circular(CatchLingoRadius.panel),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDuplicate
                              ? Icons.visibility_rounded
                              : Icons.auto_awesome_rounded,
                          color: CatchLingoColors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: CatchLingoSpacing.xs),
                        Text(
                          isDuplicate ? 'Spotted again' : 'Found it',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
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
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: CatchLingoColors.warmGreen,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: CatchLingoSpacing.xs),
                    Text(
                      word.source,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: CatchLingoColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isDuplicate) ...[
                      const SizedBox(height: CatchLingoSpacing.sm),
                      Text(
                        'Seen ${word.seenCount} times',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: CatchLingoColors.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanningHint extends StatelessWidget {
  const _ScanningHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CatchLingoSpacing.lg,
        vertical: CatchLingoSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(CatchLingoRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 16,
            color: CatchLingoColors.amber,
          ),
          const SizedBox(width: CatchLingoSpacing.sm),
          Text(
            'Looking around…',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: CatchLingoColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCompleteOverlay extends StatelessWidget {
  const _SessionCompleteOverlay({
    required this.words,
    required this.knownSeen,
    required this.onContinue,
    required this.onReview,
    required this.onExit,
  });

  final List<CatchWord> words;
  final int knownSeen;
  final VoidCallback onContinue;
  final VoidCallback? onReview;
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
                  knownSeen == 0
                      ? 'You caught ${words.length} words from this moment.'
                      : 'You caught ${words.length} new words and spotted $knownSeen you already knew.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CatchLingoColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: CatchLingoSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _SessionSummaryStat(
                        value: words.length.toString(),
                        label: 'new caught',
                        icon: Icons.add_rounded,
                        color: CatchLingoColors.warmGreen,
                      ),
                    ),
                    const SizedBox(width: CatchLingoSpacing.sm),
                    Expanded(
                      child: _SessionSummaryStat(
                        value: knownSeen.toString(),
                        label: 'seen again',
                        icon: Icons.visibility_rounded,
                        color: CatchLingoColors.amber,
                      ),
                    ),
                  ],
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
                if (onReview != null) ...[
                  FilledButton.icon(
                    onPressed: onReview,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: CatchLingoColors.warmGreen,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.style_rounded),
                    label: const Text('Review these words'),
                  ),
                  const SizedBox(height: CatchLingoSpacing.sm),
                ],
                FilledButton(
                  onPressed: onContinue,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: onReview == null
                        ? CatchLingoColors.warmGreen
                        : CatchLingoColors.warmSurface,
                    foregroundColor: onReview == null
                        ? Colors.white
                        : CatchLingoColors.warmGreen,
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

class _SessionSummaryStat extends StatelessWidget {
  const _SessionSummaryStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CatchLingoSpacing.md,
        vertical: CatchLingoSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(CatchLingoRadius.card),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: CatchLingoSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: CatchLingoColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: CatchLingoColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
