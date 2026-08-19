import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:clash_arc/common/picker.dart';
import 'package:test/test.dart';

void main() {
  group('PlatformFileExt.readBytes', () {
    test('loads bytes from the picked file path', () async {
      final directory = await Directory.systemTemp.createTemp(
        'clash_arc_picker_test_',
      );
      addTearDown(() => directory.delete(recursive: true));

      final file = File('${directory.path}/profile.yaml');
      await file.writeAsString('mixed-port: 7890');

      final platformFile = PlatformFile(
        name: 'profile.yaml',
        path: file.path,
        size: await file.length(),
      );

      final bytes = await platformFile.readBytes();

      expect(String.fromCharCodes(bytes), 'mixed-port: 7890');
    });
  });
}
