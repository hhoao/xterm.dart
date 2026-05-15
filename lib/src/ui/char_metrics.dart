import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:xterm/src/ui/terminal_text_style.dart';

/// East Asian wide character used to measure double-width cell metrics.
const _kWideCharSample = '\u4e2d\u4e2d\u4e2d\u4e2d\u4e2d';

const _kAsciiCharSample = 'mmmmmmmmmm';

Size calcCharSize(TerminalStyle style, TextScaler textScaler) {
  final regular = measureCellSizeFromTextStyle(
    style.toTextStyle(),
    textScaler,
  );
  if (!style.useBoldFontWeight) {
    return regular;
  }
  final bold = measureCellSizeFromTextStyle(
    style.toTextStyle(bold: true),
    textScaler,
  );
  return Size(
    math.max(regular.width, bold.width),
    regular.height,
  );
}

/// Lays out [textStyle] and returns one terminal cell's width and line height.
///
/// Cell width is the maximum of the average ASCII glyph width and half of a
/// typical wide (CJK) glyph width, so painted glyphs do not overlap neighbors
/// when the buffer marks characters as width 2.
Size measureCellSizeFromTextStyle(TextStyle textStyle, TextScaler textScaler) {
  final paragraphStyle = textStyle.getParagraphStyle();
  final spanStyle = textStyle.getTextStyle(textScaler: textScaler);

  Paragraph layoutSample(String sample) {
    final builder = ParagraphBuilder(paragraphStyle)
      ..pushStyle(spanStyle)
      ..addText(sample);
    final paragraph = builder.build()
      ..layout(const ParagraphConstraints(width: double.infinity));
    return paragraph;
  }

  final ascii = layoutSample(_kAsciiCharSample);
  final wide = layoutSample(_kWideCharSample);

  final asciiCellWidth = ascii.maxIntrinsicWidth / _kAsciiCharSample.length;
  final wideCellWidth = wide.maxIntrinsicWidth / _kWideCharSample.length / 2;
  final cellWidth = math.max(asciiCellWidth, wideCellWidth);
  final height = ascii.height;

  ascii.dispose();
  wide.dispose();

  return Size(cellWidth, height);
}
