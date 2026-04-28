/// Temporary local role store for showcase.
/// Used when backend access token does not include a role claim.
class DemoRoleStore {
  DemoRoleStore._();

  static final Map<String, int> _emailToRole = {};

  static void setRoleForEmail(String email, int role) {
    final key = email.trim().toLowerCase();
    if (key.isEmpty) return;
    _emailToRole[key] = role;
  }

  static int? getRoleForEmail(String email) {
    final key = email.trim().toLowerCase();
    if (key.isEmpty) return null;
    return _emailToRole[key];
  }
}

