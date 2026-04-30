import 'package:flutter_test/flutter_test.dart';
import 'package:tsl/models/shared_models.dart';
import 'package:tsl/providers/dealer_data_provider.dart';

void main() {
  group('DealerDataProvider.hasDealerPrivileges', () {
    test('returns true when profile role is dealer', () {
      expect(
        DealerDataProvider.hasDealerPrivileges(profileRole: 'dealer'),
        isTrue,
      );
    });

    test('returns true when token role is dealer', () {
      expect(
        DealerDataProvider.hasDealerPrivileges(tokenRole: 'dealer'),
        isTrue,
      );
    });

    test('returns true when synced auth role is dealer', () {
      expect(
        DealerDataProvider.hasDealerPrivileges(syncedRole: UserRole.dealer),
        isTrue,
      );
    });

    test('returns false for non-dealer roles', () {
      expect(
        DealerDataProvider.hasDealerPrivileges(
          profileRole: 'architect',
          tokenRole: 'mistri',
          syncedRole: UserRole.architect,
        ),
        isFalse,
      );
    });

    test('returns false when all role sources are missing', () {
      expect(DealerDataProvider.hasDealerPrivileges(), isFalse);
    });
  });
}

