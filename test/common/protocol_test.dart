import 'package:clash_arc/common/protocol.dart';
import 'package:test/test.dart';

void main() {
  group('ProtocolRegistrationPlan', () {
    test('builds registry writes for URL protocol registration', () {
      const plan = ProtocolRegistrationPlan(
        scheme: 'clasharc',
        executable: r'C:\Program Files\Clash Arc\Clash Arc.exe',
      );

      expect(plan.protocolKey, r'Software\Classes\clasharc');
      expect(plan.commandKey, r'shell\open\command');
      expect(plan.protocolValueName, 'URL Protocol');
      expect(plan.protocolValue, '');
      expect(plan.command, r'"C:\Program Files\Clash Arc\Clash Arc.exe" "%1"');
    });
  });
}
