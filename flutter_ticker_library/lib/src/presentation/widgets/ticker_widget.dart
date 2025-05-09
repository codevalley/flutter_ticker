import 'package:flutter/material.dart';
import '../../../src/core/utils/ticker_utils.dart';
import '../../../src/domain/entities/ticker_character_list.dart';
import '../../../src/domain/entities/ticker_column_manager.dart';
import '../../../src/domain/entities/ticker_draw_metrics.dart';

/// The primary widget for showing a ticker text view that handles smoothly scrolling from the
/// current text to a given text. The scrolling behavior is defined by
/// [setCharacterLists] which dictates what characters come in between the starting
/// and ending characters.
///
/// This class primarily handles the drawing customization of the ticker view, for example
/// setting animation duration, interpolator, colors, etc. It ensures that the canvas is properly
/// positioned, and then it delegates the drawing of each column of text to
/// [TickerColumnManager].
class TickerWidget extends StatefulWidget {
  /// The initial text to display
  final String? text;

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

  /// Creates a new ticker widget
  const TickerWidget({
    Key? key,
    this.text,
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
  }) : super(key: key);

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

      // Set initial text if provided
      if (widget.text != null) {
        _setText(widget.text!, false);
      }
    }
  }

  @override
  void didUpdateWidget(TickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation duration if it changed
    if (widget.animationDuration != oldWidget.animationDuration) {
      _animationController.duration =
          Duration(milliseconds: widget.animationDuration);
    }

    // Update animation curve if it changed
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
      _columnManager = TickerColumnManager(_metrics);

      // Reinitialize character lists and text
      if (widget.characterLists != null) {
        _columnManager.setCharacterLists(widget.characterLists!);
        if (_currentText.isNotEmpty) {
          _setText(_currentText, false);
        } else if (widget.text != null) {
          _setText(widget.text!, false);
        }
      }
    }

    // Update scrolling direction if it changed
    if (widget.preferredScrollingDirection !=
        oldWidget.preferredScrollingDirection) {
      _metrics.setPreferredScrollingDirection(
          widget.preferredScrollingDirection);
    }

    // Update character lists if they changed
    if (widget.characterLists != oldWidget.characterLists) {
      if (widget.characterLists != null) {
        _columnManager.setCharacterLists(widget.characterLists!);
      }
    }

    // Update text if it changed
    if (widget.text != oldWidget.text && widget.text != null) {
      _setText(widget.text!, true);
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
    }
    return TextStyle(
      color: widget.textColor,
      fontSize: widget.textSize,
    );
  }

  /// Called when the animation updates
  void _onAnimationUpdate() {
    setState(() {
      _columnManager.setAnimationProgress(_animation.value);
    });
  }

  /// Called when the animation status changes
  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _columnManager.onAnimationEnd();
        _isAnimating = false;

        // If we have a next text queued up, set it now
        if (_nextText != null) {
          final nextText = _nextText;
          _nextText = null;
          _setText(nextText!, true);
        }
      });
    } else if (status == AnimationStatus.forward) {
      setState(() {
        _isAnimating = true;
      });
    }
  }

  /// Sets the text to display
  void setText(String text) {
    _setText(text, true);
  }

  /// Sets the animation duration
  void setAnimationDuration(int durationMillis) {
    setState(() {
      _animationController.duration = Duration(milliseconds: durationMillis);
    });
  }

  /// Sets the text to display with the option to animate
  void _setText(String text, bool animate) {
    // If we're already animating, queue up the next text
    if (_isAnimating) {
      _nextText = text;
      return;
    }

    // If the text is the same, do nothing
    if (text == _currentText) {
      return;
    }

    // Update the current text
    _currentText = text;

    // Set the text in the column manager
    _setTextInternal(text);

    // Animate if requested
    if (animate) {
      // Reset the animation controller
      _animationController.reset();

      // Start the animation after a delay if specified
      if (widget.animationDelay > 0) {
        Future.delayed(Duration(milliseconds: widget.animationDelay), () {
          if (mounted) {
            _animationController.forward();
          }
        });
      } else {
        _animationController.forward();
      }
    } else {
      // If not animating, set the animation progress to the end
      _columnManager.setAnimationProgress(1.0);
      _columnManager.onAnimationEnd();
    }
  }

  /// Sets the text internally
  void _setTextInternal(String text) {
    _columnManager.setText(text);
    _checkForRelayout();
  }

  /// Checks if the layout needs to be updated
  void _checkForRelayout() {
    final desiredWidth = _computeDesiredWidth();
    final desiredHeight = _computeDesiredHeight();

    if (desiredWidth != _lastMeasuredDesiredWidth ||
        desiredHeight != _lastMeasuredDesiredHeight) {
      setState(() {});
    }
  }

  /// Computes the desired width of the ticker
  double _computeDesiredWidth() {
    // Get the base width from the column manager
    final baseWidth = _columnManager.getCurrentWidth();

    // Add letter spacing between characters
    final int numColumns = _columnManager.tickerColumns.length;
    final double letterSpacingWidth = numColumns > 0
        ? (numColumns - 1) * widget.letterSpacing
        : 0;

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
    final currentWidth =
        columnManager.getCurrentWidth() +
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
      if (currentChar == TickerUtils.EMPTY_CHAR) {
        continue;
      }

      // Draw the current column at the calculated offset
      canvas.save();
      canvas.translate(xOffset, 0);
      column.draw(canvas, textPainter);
      canvas.restore();

      // Get the next character for spacing calculation
      String nextChar = TickerUtils.EMPTY_CHAR;
      if (i < columnManager.tickerColumns.length - 1) {
        nextChar = columnManager.tickerColumns[i + 1].getCurrentChar();
      }

      // Get the current character width
      final charWidth = column.getCurrentWidth();

      // Calculate ideal spacing between current and next character
      // using our enhanced metrics calculator
      double idealSpacing = metrics.getIdealSpacingBetween(
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
