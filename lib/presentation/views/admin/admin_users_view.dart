import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/core/theme/app_colors.dart';
import 'package:manzili_mobile/presentation/widgets/common/soft_card.dart';
import 'package:manzili_mobile/presentation/providers/admin_provider.dart';
import 'package:provider/provider.dart';

class AdminUsersView extends StatefulWidget {
  const AdminUsersView({super.key});

  @override
  State<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<AdminUsersView> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  static const int _pageSize = 15;
  bool _loadingMore = false;

  // Filter state (local mirror for UI)
  String? _selectedRole; // null = all
  bool? _selectedIsBlocked; // null = all

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPage(1, reset: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadPage(int page, {bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
    }
    await context.read<AdminProvider>().fetchUsers(
          page: page,
          pageSize: _pageSize,
          role: _selectedRole,
          isBlocked: _selectedIsBlocked,
        );
  }

  Future<void> _loadMore() async {
    final provider = context.read<AdminProvider>();
    final res = provider.usersResponse;
    if (res == null || _loadingMore || provider.isLoading) return;
    final totalLoaded = res.items.length;
    if (totalLoaded >= res.totalCount) return;

    setState(() => _loadingMore = true);
    _currentPage++;
    await provider.fetchUsers(
      page: _currentPage,
      pageSize: _pageSize,
      role: _selectedRole,
      isBlocked: _selectedIsBlocked,
    );
    setState(() => _loadingMore = false);
  }

  Future<void> _onRefresh() async {
    _currentPage = 1;
    await _loadPage(1, reset: true);
  }

  void _applyFilters({String? role, bool? isBlocked}) {
    setState(() {
      _selectedRole = role;
      _selectedIsBlocked = isBlocked;
      _currentPage = 1;
    });
    context.read<AdminProvider>().fetchUsers(
          page: 1,
          pageSize: _pageSize,
          role: role,
          isBlocked: isBlocked,
        );
  }

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'provider':
        return Colors.blue;
      case 'admin':
        return AppColors.primary;
      case 'buyer':
      default:
        return AppColors.sageGreen;
    }
  }

  String _roleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'provider':
        return 'مزود';
      case 'admin':
        return 'أدمن';
      case 'buyer':
        return 'مشتري';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
      ),
      body: Column(
        children: [
          // ── Filter bar ──────────────────────────────────────────────
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Role chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _RoleChip(
                        label: 'الكل',
                        selected: _selectedRole == null,
                        onTap: () => _applyFilters(role: null, isBlocked: _selectedIsBlocked),
                      ),
                      const SizedBox(width: 8),
                      _RoleChip(
                        label: 'مشتري',
                        selected: _selectedRole == 'Buyer',
                        color: AppColors.sageGreen,
                        onTap: () => _applyFilters(role: 'Buyer', isBlocked: _selectedIsBlocked),
                      ),
                      const SizedBox(width: 8),
                      _RoleChip(
                        label: 'مزود',
                        selected: _selectedRole == 'Provider',
                        color: Colors.blue,
                        onTap: () => _applyFilters(role: 'Provider', isBlocked: _selectedIsBlocked),
                      ),
                      const SizedBox(width: 8),
                      _RoleChip(
                        label: 'أدمن',
                        selected: _selectedRole == 'Admin',
                        color: AppColors.primary,
                        onTap: () => _applyFilters(role: 'Admin', isBlocked: _selectedIsBlocked),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Blocked toggle
                Row(
                  children: [
                    const Text('موقوفين فقط', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    Switch.adaptive(
                      value: _selectedIsBlocked == true,
                      activeThumbColor: Colors.red,
                      activeTrackColor: Colors.red.withValues(alpha: 0.4),
                      onChanged: (val) => _applyFilters(
                        role: _selectedRole,
                        isBlocked: val ? true : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // ── List ────────────────────────────────────────────────────
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.usersResponse == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.errorMessage != null && provider.usersResponse == null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          provider.errorMessage!,
                          style: const TextStyle(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _onRefresh,
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }

                final users = provider.usersResponse?.items ?? [];

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people_outline, size: 64, color: AppColors.textHint),
                        const SizedBox(height: 16),
                        const Text('مفيش مستخدمين هنا', style: TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _onRefresh,
                          icon: const Icon(Icons.refresh),
                          label: const Text('تحديث'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: users.length + (_loadingMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == users.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final u = users[index];
                      final isActive = !u.isBlocked;
                      final initials = u.fullName.isNotEmpty
                          ? u.fullName.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join()
                          : '?';
                      final joinDate = u.createdAt != null
                          ? '${u.createdAt!.day.toString().padLeft(2, '0')}/${u.createdAt!.month.toString().padLeft(2, '0')}/${u.createdAt!.year}'
                          : 'غير معروف';

                      return SoftCard(
                        onTap: () async {
                          await context.push('/admin/users/details/${u.id}');
                          if (context.mounted) {
                            _onRefresh();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: _roleColor(u.role).withValues(alpha: 0.15),
                                backgroundImage: u.profilePicture.isNotEmpty
                                    ? NetworkImage(u.profilePicture)
                                    : null,
                                child: u.profilePicture.isEmpty
                                    ? Text(
                                        initials,
                                        style: TextStyle(
                                          color: _roleColor(u.role),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      u.fullName.isNotEmpty ? u.fullName : 'بدون اسم',
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        // Role badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _roleColor(u.role).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            _roleLabel(u.role),
                                            style: TextStyle(
                                              color: _roleColor(u.role),
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Status badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? AppColors.statusActive.withValues(alpha: 0.1)
                                                : Colors.red.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            isActive ? 'نشط' : 'موقوف',
                                            style: TextStyle(
                                              color: isActive ? AppColors.statusActive : Colors.red,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'تاريخ الانضمام: $joinDate',
                                      style: const TextStyle(
                                        color: AppColors.textHint,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.textHint),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? activeColor : AppColors.roleUnselectedBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
