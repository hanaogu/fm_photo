import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_photo/fm_photo.dart';

void main() {
  const MethodChannel channel = MethodChannel('fm_photo');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
