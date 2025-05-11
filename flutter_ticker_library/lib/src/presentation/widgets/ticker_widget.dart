import 'package:flutter/material.dart';
import '../../../src/core/utils/ticker_utils.dart';
import '../../../src/domain/entities/ticker_character_list.dart';
import '../../../src/domain/entities/ticker_column_manager.dart';
import '../../../src/domain/entities/ticker_draw_metrics.dart';

/// The primary widget for showing a ticker text view that handles smoothly scrolling from the
/// current text to a given text. The scrolling behavior is defined by
/// the character lists which dictate what characters come in between the starting
/// and ending characters.
///
/// This class primarily handles the drawing customization of the ticker view, for example
/// setting animation duration, interpolator, colors, etc. It ensures that the canvas is properly
/// positioned, and then it delegates the drawing of each column of text to
/// [TickerColumnManager].
class TickerWidget extends StatefulWidget {
  /// The text to display (target text for animation)
  final String? text;

  /// The initial text to display before animation
  final String? initialValue;

  /// Whether to animate from initialValue to text on first render
  final bool animateOnLoad;

  /// The text color
  final Color textColor;

  /// The text size
  final double textSize;

  /// The text style
  final TextStyle? textStyle;

  /// The animation duration in milliseconds
  final int animationDuration;

  /// The animation curve
  final Curve animationCurve;

  /// The preferred scrolling direction
  final ScrollingDirection preferredScrollingDirection;

  /// The gravity (alignment) of the text
  final Alignment gravity;

  /// Whether to animate measurement changes
  final bool animateMeasurementChange;

  /// The delay before animation starts in milliseconds
  final int animationDelay;

  /// The character lists to use for animations
  final List<String>? characterLists;

  /// The letter spacing between characters
  final double letterSpacing;

  /// Additional padding to prevent clipping
  final EdgeInsets padding;

  /// Callback that is called when the animation completes
  final VoidCallback? onAnimationComplete;

  /// Creates a new ticker widget
  const TickerWidget({
    super.key,
    this.text,
    this.initialValue,
    this.animateOnLoad = false,
    this.textColor = Colors.black,
    this.textSize = 12.0,
    this.textStyle,
    this.animationDuration = 950,
    this.animationCurve = Curves.easeInOut,
    this.preferredScrollingDirection = ScrollingDirection.any,
    this.gravity = Alignment.centerLeft,
    this.animateMeasurementChange = false,
    this.animationDelay = 0,
    this.characterLists,
    this.letterSpacing = 1.0,
    this.padding = const EdgeInsets.all(2.0),
    this.onAnimationComplete,
  });

  @override
  State<TickerWidget> createState() => TickerWidgetState();
}

class TickerWidgetState extends State<TickerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  late TextPainter _textPainter;
  late TickerDrawMetrics _metrics;
  late TickerColumnManager _columnManager;

  String _currentText = '';
  String? _nextText;
  bool _isAnimating = false;

  double _lastMeasuredDesiredWidth = 0;
  double _lastMeasuredDesiredHeight = 0;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.animationDuration),
    );

    // Create the animation with the specified curve
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    );

    // Set up the animation listener
    _animation.addListener(_onAnimationUpdate);
    _animationController.addStatusListener(_onAnimationStatus);

    // Initialize text painter
    _textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(text: '', style: _getTextStyle()),
    );

    // Initialize metrics and column manager
    _metrics = TickerDrawMetrics(textStyle: _getTextStyle());
    _metrics.setPreferredScrollingDirection(widget.preferredScrollingDirection);
    _columnManager = TickerColumnManager(_metrics);

    // Set character lists if provided
    if (widget.characterLists != null) {
      _columnManager.setCharacterLists(widget.characterLists!);

      // Handle initialValue and text setup
      if (widget.initialValue != null &&
          widget.text != null &&
          widget.animateOnLoad) {
        // Set initial value without animation first
        _setText(widget.initialValue!, false);
        // Then animate to the target text
        Future.microtask(() {
          if (mounted) {
            _setText(widget.text!, true);
          }
        });
      } else if (widget.initialValue != null && widget.text == null) {
        // Only initialValue provided, no animation
        _setText(widget.initialValue!, false);
      } else if (widget.text != null) {
        // Only text provided or animateOnLoad is false
        _setText(widget.text!, false);
      }
    }
  }

  @override
  void didUpdateWidget(TickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation properties if they changed
    if (widget.animationDuration != oldWidget.animationDuration) {
      _animationController.duration = Duration(
        milliseconds: widget.animationDuration,
      );
    }

    if (widget.animationCurve != oldWidget.animationCurve) {
      _animation = CurvedAnimation(
        parent: _animationController,
        curve: widget.animationCurve,
      );
      _animation.addListener(_onAnimationUpdate);
    }

    // Update text style if it changed
    if (widget.textColor != oldWidget.textColor ||
        widget.textSize != oldWidget.textSize ||
        widget.textStyle != oldWidget.textStyle) {
      _textPainter.text = TextSpan(text: '', style: _getTextStyle());
      _metrics = TickerDrawMetrics(textStyle: _getTextStyle());
      _metrics.setPreferredScrollingDirection(
        widget.preferredScrollingDirection,
      );
      _columnManager = TickerColumnManager(_metrics);

      if (widget.characterLists != null) {
        _columnManager.setCharacterLists(widget.characterLists!);
        _setText(_currentText, false);
      }
    }

    // Update scrolling direction if it changed
    if (widget.preferredScrollingDirection !=
        oldWidget.preferredScrollingDirection) {
      _metrics.setPreferredScrollingDirection(
        widget.preferredScrollingDirection,
      );
    }

    // Update character lists if they changed
    if (widget.characterLists != oldWidget.characterLists &&
        widget.characterLists != null) {
      _columnManager.setCharacterLists(widget.characterLists!);
    }

    // Update text if it changed
    if (widget.text != oldWidget.text &&
        widget.text != null &&
        widget.text != _currentText) {
      // If initialValue is set and animateOnLoad is true, animate to the new text
      if (widget.initialValue != null &&
          widget.animateOnLoad &&
          _currentText == widget.initialValue) {
        setText(widget.text!);
      } else {
        setText(widget.text!);
      }
    }

    // Handle initialValue changes
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != null &&
        _currentText.isEmpty) {
      _setText(widget.initialValue!, false);
    }
  }

  @override
  void dispose() {
    _animationController.removeStatusListener(_onAnimationStatus);
    _animation.removeListener(_onAnimationUpdate);
    _animationController.dispose();
    super.dispose();
  }

  /// Gets the text style to use for the ticker
  TextStyle _getTextStyle() {
    if (widget.textStyle != null) {
      return widget.textStyle!.copyWith(
        color: widget.textColor,
        fontSize: widget.textSize,
      );
    } else {
      return TextStyle(color: widget.textColor, fontSize: widget.textSize);
    }
  }

  /// Called when the animation updates
  void _onAnimationUpdate() {
    _columnManager.setAnimationProgress(_animation.value);
    _checkForRelayout();
    setState(() {});
  }

  /// Called when the animation status changes
  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _columnManager.onAnimationEnd();
      _checkForRelayout();
      setState(() {
        _isAnimating = false;
      });

      // Call the onAnimationComplete callback if provided
      if (widget.onAnimationComplete != null) {
        widget.onAnimationComplete!();
      }

      // Start the next animation if there is one
      if (_nextText != null) {
        final nextText = _nextText;
        _nextText = null;
        Future.delayed(Duration(milliseconds: widget.animationDelay), () {
          if (mounted) {
            _setText(nextText!, true);
          }
        });
      }
    }
  }

  /// Sets the text to display
  void setText(String text) {
    _setText(text, true);
  }

  /// Triggers animation from initialValue to the target text
  /// If a new text is provided, it will animate from initialValue to that new text
  /// Otherwise, it will animate from initialValue to the current text value
  void animate([String? newText]) {
    if (widget.initialValue == null) {
      // If no initialValue is set, fall back to regular setText behavior
      if (newText != null && newText != _currentText) {
        setText(newText);
      } else {
        // Just replay the current animation
        _animationController.reset();
        _animationController.forward();
      }
      return;
    }

    // Store the target text (either the new text or current text)
    final targetText = newText ?? _currentText;

    // First set to initialValue without animation
    _setText(widget.initialValue!, false);

    // Then animate to the target text
    Future.microtask(() {
      if (mounted) {
        if (targetText != widget.initialValue) {
          setText(targetText);
        }
      }
    });
  }

  /// Sets the animation duration
  void setAnimationDuration(int durationMillis) {
    if (_animationController.duration?.inMilliseconds != durationMillis) {
      _animationController.duration = Duration(milliseconds: durationMillis);
    }
  }

  /// Sets the text to display with the option to animate
  void _setText(String text, bool animate) {
    if (text == _currentText) {
      return;
    }

    if (!animate && _isAnimating) {
      _animationController.stop();
      _isAnimating = false;
      _nextText = null;
    }

    if (animate) {
      if (_isAnimating) {
        // Queue up this text change for after the current animation
        _nextText = text;
      } else {
        _setTextInternal(text);
        _isAnimating = true;

        // Start the animation after the specified delay
        Future.delayed(Duration(milliseconds: widget.animationDelay), () {
          if (mounted) {
            _animationController.forward(from: 0.0);
          }
        });
      }
    } else {
      _setTextInternal(text);
      _columnManager.setAnimationProgress(1.0);
      _columnManager.onAnimationEnd();
      _checkForRelayout();
      setState(() {});
    }
  }

  /// Sets the text internally
  void _setTextInternal(String text) {
    _currentText = text;
    _columnManager.setText(text);
  }

  /// Checks if the layout needs to be updated
  void _checkForRelayout() {
    final widthChanged = _lastMeasuredDesiredWidth != _computeDesiredWidth();
    final heightChanged = _lastMeasuredDesiredHeight != _computeDesiredHeight();

    if (widthChanged || heightChanged) {
      setState(() {});
    }
  }

  /// Computes the desired width of the ticker
  double _computeDesiredWidth() {
    final baseWidth = widget.animateMeasurementChange
        ? _columnManager.getCurrentWidth()
        : _columnManager.getMinimumRequiredWidth();

    // Add letter spacing between characters
    final letterSpacingWidth = _columnManager.tickerColumns.isNotEmpty
        ? widget.letterSpacing * (_columnManager.tickerColumns.length - 1)
        : 0.0;

    return baseWidth + letterSpacingWidth + widget.padding.horizontal;
  }

  /// Computes the desired height of the ticker
  double _computeDesiredHeight() {
    return _metrics.getCharHeight() + widget.padding.vertical;
  }

  @override
  Widget build(BuildContext context) {
    _lastMeasuredDesiredWidth = _computeDesiredWidth();
    _lastMeasuredDesiredHeight = _computeDesiredHeight();

    return Padding(
      padding: widget.padding,
      child: CustomPaint(
        size: Size(_lastMeasuredDesiredWidth, _lastMeasuredDesiredHeight),
        painter: _TickerPainter(
          columnManager: _columnManager,
          metrics: _metrics,
          textPainter: _textPainter,
          gravity: widget.gravity,
          letterSpacing: widget.letterSpacing,
        ),
      ),
    );
  }
}

/// Custom painter for the ticker widget
class _TickerPainter extends CustomPainter {
  final TickerColumnManager columnManager;
  final TickerDrawMetrics metrics;
  final TextPainter textPainter;
  final Alignment gravity;
  final double letterSpacing;

  _TickerPainter({
    required this.columnManager,
    required this.metrics,
    required this.textPainter,
    required this.gravity,
    this.letterSpacing = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    // Align the canvas based on gravity
    final currentWidth = columnManager.getCurrentWidth() +
        (letterSpacing * (columnManager.tickerColumns.length - 1));
    final currentHeight = metrics.getCharHeight();

    double translationX = 0;
    double translationY = 0;

    // Calculate translation based on gravity
    if (gravity == Alignment.center ||
        gravity == Alignment.topCenter ||
        gravity == Alignment.bottomCenter) {
      translationX = (size.width - currentWidth) / 2;
    } else if (gravity == Alignment.centerRight ||
        gravity == Alignment.topRight ||
        gravity == Alignment.bottomRight) {
      translationX = size.width - currentWidth;
    }

    if (gravity == Alignment.center ||
        gravity == Alignment.centerLeft ||
        gravity == Alignment.centerRight) {
      translationY = (size.height - currentHeight) / 2;
    } else if (gravity == Alignment.bottomCenter ||
        gravity == Alignment.bottomLeft ||
        gravity == Alignment.bottomRight) {
      translationY = size.height - currentHeight;
    }

    canvas.translate(translationX, translationY);

    // Add a small padding to prevent clipping
    final clipRect = Rect.fromLTWH(-2, -2, currentWidth + 4, currentHeight + 4);
    canvas.clipRect(clipRect);

    // Canvas.drawText writes the text on the baseline so we need to translate beforehand
    canvas.translate(0, metrics.getCharBaseline());

    // Draw the ticker columns with proper character spacing
    double xOffset = 0;
    for (int i = 0; i < columnManager.tickerColumns.length; i++) {
      final column = columnManager.tickerColumns[i];
      final currentChar = column.getCurrentChar();

      // Skip empty characters
      if (currentChar == TickerUtils.emptyChar) {
        continue;
      }

      // Draw the current column at the calculated offset
      canvas.save();
      canvas.translate(xOffset, 0);
      column.draw(canvas, textPainter);
      canvas.restore();

      // Get the next character for spacing calculation
      String nextChar = TickerUtils.emptyChar;
      if (i < columnManager.tickerColumns.length - 1) {
        nextChar = columnManager.tickerColumns[i + 1].getCurrentChar();
      }

      // Get the current character width
      final charWidth = column.getCurrentWidth();

      // Calculate ideal spacing between current and next character
      // using our enhanced metrics calculator
      final double idealSpacing = metrics.getIdealSpacingBetween(
        currentChar,
        nextChar,
        letterSpacing,
      );

      // Update the x offset for the next character
      xOffset += charWidth + idealSpacing;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_TickerPainter oldDelegate) {
    return true;
  }
}
