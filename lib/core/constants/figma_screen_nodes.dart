/// Figma file **New Capstone Manzili** — node ids for **Manzili mobile** screens.
///
/// Use with MCP `get_design_context` / `get_metadata`:
/// `fileKey` + `nodeId` (format `123:456` or `123-456` in URLs).
///
/// Browser deep link: [figmaDesignUrl].
class FigmaManziliNodes {
  FigmaManziliNodes._();

  static const String fileKey = 'gJiDAzijtWW1n2JCueEzET';

  /// Section container in the file (optional parent context).
  static const String sectionManziliMobile = '1085:6835';

  static const String signUp = '1226:7724';
  static const String signIn = '1155:6904';
  static const String home = '1099:7193';

  /// Two variants of the services list exist in the file.
  static const String servicesPage = '1134:6988';
  static const String servicesPageAlt = '1150:6921';

  static const String serviceDetailsPage = '1150:7135';
  static const String reviewsPage = '1229:8087';
  static const String exploreSellerPage = '1150:7134';
  static const String favouritesPage = '1227:7919';
  static const String notificationsPage = '1229:8262';
  static const String ordersPage = '1259:7882';
  static const String cartPage = '1195:7068';
  static const String orderPlacedPage = '1319:7377';
  static const String trackOrdersPage = '1320:7470';

  /// `nodeId` like `1099:7193` → Figma URL query `node-id=1099-7193`
  static String figmaNodeQueryParam(String nodeId) =>
      nodeId.replaceAll(':', '-');

  /// Opens the file on the given frame/section.
  static Uri figmaDesignUrl(String nodeId) => Uri.parse(
        'https://www.figma.com/design/$fileKey/New-Capstone-Manzili'
        '?node-id=${figmaNodeQueryParam(nodeId)}',
      );
}
