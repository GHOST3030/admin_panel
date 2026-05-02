import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/breakpoints.dart';
import '../../../core/responsive/responsive_helper.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../auth/presentation/states/auth_state.dart';

// ── Nav item model ────────────────────────────────────────────
class _NavItem {
  const _NavItem(
      {required this.icon, required this.label, required this.route,});
  final IconData icon;
  final String label;
  final String route;
}

const _navItems = [
  _NavItem(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
      route: AppRoutes.dashboard,),
  _NavItem(
      icon: Icons.category_rounded,
      label: 'Categories',
      route: AppRoutes.categories,),
  _NavItem(
      icon: Icons.inventory_2_rounded,
      label: 'Products',
      route: AppRoutes.products,),
  _NavItem(
      icon: Icons.receipt_long_rounded,
      label: 'Orders',
      route: AppRoutes.orders,),
];

// ── Provider for sidebar collapsed state ──────────────────────
final _sidebarCollapsedProvider = StateProvider<bool>((ref) => false);

// ══════════════════════════════════════════════════════════════
// ROOT SHELL
// ══════════════════════════════════════════════════════════════
class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (context.usesDrawer) {
      return _MobileShell(child: child);
    }
    if (context.hasCollapsibleSidebar) {
      return _TabletShell(child: child);
    }
    return _DesktopShell(child: child);
  }
}

// ══════════════════════════════════════════════════════════════
// DESKTOP SHELL — fixed sidebar + topbar
// ══════════════════════════════════════════════════════════════
class _DesktopShell extends ConsumerWidget {
  const _DesktopShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collapsed = ref.watch(_sidebarCollapsedProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: Row(
        children: [
          _Sidebar(collapsed: collapsed),
          Expanded(
            child: Column(
              children: [
                _Topbar(
                  onMenuTap: () => ref
                      .read(_sidebarCollapsedProvider.notifier)
                      .state = !collapsed,
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// TABLET SHELL — collapsible icon sidebar
// ══════════════════════════════════════════════════════════════
class _TabletShell extends ConsumerWidget {
  const _TabletShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collapsed = ref.watch(_sidebarCollapsedProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: Row(
        children: [
          _Sidebar(collapsed: collapsed),
          Expanded(
            child: Column(
              children: [
                _Topbar(
                  onMenuTap: () => ref
                      .read(_sidebarCollapsedProvider.notifier)
                      .state = !collapsed,
                  compact: true,
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// MOBILE SHELL — drawer
// ══════════════════════════════════════════════════════════════
class _MobileShell extends ConsumerWidget {
  const _MobileShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      drawer: const _DrawerSidebar(),
      appBar: const _Topbar(showDrawerMenu: true),
      body: child,
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SIDEBAR
// ══════════════════════════════════════════════════════════════
class _Sidebar extends ConsumerWidget {
  const _Sidebar({required this.collapsed});
  final bool collapsed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final width =
        collapsed ? Breakpoints.sidebarCollapsed : Breakpoints.sidebarWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: width,
      decoration: BoxDecoration(
        color: AppTheme.sidebarColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _SidebarHeader(collapsed: collapsed),
          const Divider(height: 1, color: Colors.white12),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              children: _navItems
                  .map(
                    (item) => _SidebarTile(
                      item: item,
                      collapsed: collapsed,
                      selected: location == item.route ||
                          (item.route != AppRoutes.dashboard &&
                              location.startsWith(item.route)),
                    ),
                  )
                  .toList(),
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          _SidebarSignOut(collapsed: collapsed, ref: ref),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({required this.collapsed});
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: collapsed
            ? const Center(
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              )
            : const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white70,
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.item,
    required this.collapsed,
    required this.selected,
  });
  final _NavItem item;
  final bool collapsed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? Colors.white : Colors.white.withValues(alpha: 0.65);
    final bg =
        selected ? Colors.white.withValues(alpha: 0.12) : Colors.transparent;

    return Tooltip(
      message: collapsed ? item.label : '',
      preferBelow: false,
      child: InkWell(
        onTap: () => context.go(item.route),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 0 : 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: collapsed
              ? Center(child: Icon(item.icon, color: color, size: 22))
              : Row(
                  children: [
                    Icon(item.icon, color: color, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: color,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SidebarSignOut extends StatelessWidget {
  const _SidebarSignOut({required this.collapsed, required this.ref});
  final bool collapsed;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: collapsed ? 'Sign Out' : '',
      child: InkWell(
        onTap: () => ref.read(authNotifierProvider.notifier).signOut(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 0 : 20,
            vertical: 14,
          ),
          child: collapsed
              ? const Center(
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.white60,
                    size: 20,
                  ),
                )
              : const Row(
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.white60, size: 18),
                    SizedBox(width: 12),
                    Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// DRAWER (mobile)
// ══════════════════════════════════════════════════════════════
class _DrawerSidebar extends ConsumerWidget {
  const _DrawerSidebar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    return Drawer(
      backgroundColor: AppTheme.sidebarColor,
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.transparent),
            child: Row(
              children: [
                Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: _navItems
                  .map(
                    (item) => _SidebarTile(
                      item: item,
                      collapsed: false,
                      selected: location == item.route ||
                          (item.route != AppRoutes.dashboard &&
                              location.startsWith(item.route)),
                    ),
                  )
                  .toList(),
            ),
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.white60),
            title: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white60),
            ),
            onTap: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// TOPBAR
// ══════════════════════════════════════════════════════════════
class _Topbar extends ConsumerWidget implements PreferredSizeWidget {
  const _Topbar({
    this.onMenuTap,
    this.compact = false,
    this.showDrawerMenu = false,
  });

  final VoidCallback? onMenuTap;
  final bool compact;
  final bool showDrawerMenu;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider).valueOrNull;
    final userEmail =
        authState is AuthAuthenticated ? authState.user.email : '';

    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          if (showDrawerMenu)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            )
          else if (onMenuTap != null)
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: onMenuTap,
              tooltip: 'Toggle sidebar',
            ),
          const Spacer(),
          if (!compact) ...[
            Text(
              userEmail,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(width: 16),
          ],
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'A',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
