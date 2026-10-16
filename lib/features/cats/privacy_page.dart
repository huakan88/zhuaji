import '../legal/legal_copy.dart';
import '../legal/legal_page.dart';

export '../legal/legal_copy.dart' show privacySections;

class PrivacyPage extends LegalPage {
  const PrivacyPage({super.key})
    : super(title: '隐私政策', sections: privacySections);
}
