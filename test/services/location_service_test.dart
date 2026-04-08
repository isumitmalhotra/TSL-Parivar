import 'package:flutter_test/flutter_test.dart';
import 'package:tsl/services/location_service.dart';

void main() {
  group('LocationService helpers', () {
    test('valid coordinates pass sanity check', () {
      expect(LocationService.isValidCoordinates(28.6139, 77.2090), isTrue);
    });

    test('invalid coordinates fail sanity check', () {
      expect(LocationService.isValidCoordinates(120.0, 77.2090), isFalse);
      expect(LocationService.isValidCoordinates(28.6139, 220.0), isFalse);
    });

    test('address usability checks non-empty text', () {
      expect(LocationService.isAddressUsable('Sector 62, Noida'), isTrue);
      expect(LocationService.isAddressUsable('  '), isFalse);
      expect(LocationService.isAddressUsable(null), isFalse);
    });
  });
}

