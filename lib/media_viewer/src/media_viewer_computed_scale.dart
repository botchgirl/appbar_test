import 'package:flutter/widgets.dart';

@immutable
class MediaViewerComputedScale {
  const MediaViewerComputedScale._internal(this._value, [this.multiplier = 1.0]);

  final String _value;
  final double multiplier;

  @override
  String toString() => 'Enum.$_value';

  static const contained = MediaViewerComputedScale._internal('contained');
  static const covered = MediaViewerComputedScale._internal('covered');

  MediaViewerComputedScale operator *(double multiplier) {
    return MediaViewerComputedScale._internal(_value, multiplier);
  }

  MediaViewerComputedScale operator /(double divider) {
    return MediaViewerComputedScale._internal(_value, 1 / divider);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaViewerComputedScale && runtimeType == other.runtimeType && _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}
