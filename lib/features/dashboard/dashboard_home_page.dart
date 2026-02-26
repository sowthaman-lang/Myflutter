import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/localization/locale_controller.dart';
import '../../core/storage/user_defaults.dart';
import '../../core/theme/theme_controller.dart';
import '../auth/login_page.dart';
import 'sales_models.dart';

class DashboardHomePage extends StatefulWidget {
  const DashboardHomePage({
    super.key,
    required this.themeController,
    required this.localeController,
    required this.signedInUser,
  });

  final ThemeController themeController;
  final LocaleController localeController;
  final SalesUser signedInUser;

  @override
  State<DashboardHomePage> createState() => _DashboardHomePageState();
}

class _DashboardHomePageState extends State<DashboardHomePage> {
  int _menuIndex = 0;
  int _productRefreshToken = 0;

  static const _allMenus = <_MenuItem>[
    _MenuItem(
      key: 'dashboard',
      title: 'Dashboard',
      icon: Icons.space_dashboard_rounded,
      allowedRoles: {SalesRole.admin, SalesRole.supervisor, SalesRole.salesManager},
    ),
    _MenuItem(
      key: 'salesLedger',
      title: 'Sales Ledger',
      icon: Icons.receipt_long_rounded,
      allowedRoles: {SalesRole.admin, SalesRole.supervisor, SalesRole.salesManager},
    ),
    _MenuItem(
      key: 'invoices',
      title: 'Invoices',
      icon: Icons.request_quote_rounded,
      allowedRoles: {SalesRole.admin, SalesRole.supervisor, SalesRole.salesManager},
    ),
    _MenuItem(
      key: 'team',
      title: 'Team',
      icon: Icons.diversity_3_rounded,
      allowedRoles: {SalesRole.admin, SalesRole.supervisor},
    ),
    _MenuItem(
      key: 'products',
      title: 'Products',
      icon: Icons.inventory_rounded,
      allowedRoles: {SalesRole.admin, SalesRole.supervisor},
    ),
    _MenuItem(
      key: 'addProduct',
      title: 'Add Product',
      icon: Icons.add_box_rounded,
      allowedRoles: {SalesRole.admin},
    ),
    _MenuItem(
      key: 'vendorOrders',
      title: 'Vendor Orders',
      icon: Icons.shopping_cart_checkout_rounded,
      allowedRoles: {SalesRole.salesManager},
    ),
    _MenuItem(
      key: 'payments',
      title: 'Payments',
      icon: Icons.account_balance_wallet_rounded,
      allowedRoles: {SalesRole.admin},
    ),
    _MenuItem(
      key: 'reports',
      title: 'Reports',
      icon: Icons.analytics_rounded,
      allowedRoles: {SalesRole.admin},
    ),
  ];

  List<_MenuItem> get _menus {
    final role = widget.signedInUser.role;
    return _allMenus.where((m) => m.allowedRoles.contains(role)).toList();
  }

  int get _safeMenuIndex {
    if (_menus.isEmpty) return 0;
    if (_menuIndex >= _menus.length) return _menus.length - 1;
    return _menuIndex;
  }

  List<SalesRecord> get _records => SalesVisibility.visibleRecords(widget.signedInUser);

  Set<String> get _visibleUserIds =>
      SalesVisibility.visibleUserIds(widget.signedInUser, DemoSalesData.users);

  List<SalesUser> get _visibleUsers =>
      DemoSalesData.users.where((u) => _visibleUserIds.contains(u.id)).toList();

  int get _totalSales => _records.fold<int>(0, (sum, r) => sum + r.total);
  int get _totalCollected => _records.fold<int>(0, (sum, r) => sum + r.paid);
  int get _totalOutstanding => _records.fold<int>(0, (sum, r) => sum + r.balance);

  String get _scopeText {
    switch (widget.signedInUser.role) {
      case SalesRole.admin:
        return 'Scope: All company sales';
      case SalesRole.supervisor:
        return 'Scope: Your team and your sales';
      case SalesRole.salesManager:
        return 'Scope: Only your sales';
    }
  }

  String get _roleLabel {
    switch (widget.signedInUser.role) {
      case SalesRole.admin:
        return 'Admin';
      case SalesRole.supervisor:
        return 'Supervisor';
      case SalesRole.salesManager:
        return 'SalesManager';
    }
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => LoginPage(
          themeController: widget.themeController,
          localeController: widget.localeController,
        ),
      ),
      (route) => false,
    );
  }

  Future<void> _toggleTheme() async {
    final current = widget.themeController.themeMode;
    if (current == ThemeMode.system) return widget.themeController.setThemeMode(ThemeMode.light);
    if (current == ThemeMode.light) return widget.themeController.setThemeMode(ThemeMode.dark);
    await widget.themeController.setThemeMode(ThemeMode.system);
  }

  Future<void> _toggleLanguage() async {
    final current = widget.localeController.locale.languageCode;
    final next = current == AppStrings.languageEnglish
        ? AppStrings.languageHindi
        : AppStrings.languageEnglish;
    await widget.localeController.setLocale(Locale(next));
  }

  Widget _currentScreen() {
    if (_menus.isEmpty) return const SizedBox.shrink();
    final selectedMenu = _menus[_safeMenuIndex];
    switch (selectedMenu.key) {
      case 'dashboard':
        return _OverviewScreen(
          user: widget.signedInUser,
          records: _records,
          totalSales: _totalSales,
          totalCollected: _totalCollected,
          totalOutstanding: _totalOutstanding,
        );
      case 'salesLedger':
        return _LedgerScreen(records: _records);
      case 'invoices':
        return _InvoiceScreen(records: _records);
      case 'team':
        return _TeamScreen(
          visibleUsers: _visibleUsers,
          records: _records,
        );
      case 'products':
        return _ProductsScreen(
          refreshToken: _productRefreshToken,
          canManage: widget.signedInUser.role == SalesRole.admin,
        );
      case 'addProduct':
        return _AddProductScreen(
          onProductSaved: () {
            setState(() => _productRefreshToken++);
          },
        );
      case 'vendorOrders':
        return _VendorOrderScreen(signedInUser: widget.signedInUser);
      case 'payments':
        return _PaymentsScreen(records: _records);
      case 'reports':
        return _ReportsScreen(records: _records);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _sideMenu(bool isPhone) {
    final content = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.sports_basketball_rounded),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Enterprise Console',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.signedInUser.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  _roleLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(_scopeText, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _menus.length,
            itemBuilder: (context, i) {
              final m = _menus[i];
              return ListTile(
                leading: Icon(m.icon),
                title: Text(m.title),
                selected: _menuIndex == i,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onTap: () {
                  setState(() => _menuIndex = i);
                  if (isPhone) Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.logout_rounded),
          title: const Text('Logout'),
          onTap: _logout,
        ),
      ],
    );

    if (isPhone) return Drawer(child: content);

    return Container(
      width: 290,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: content,
    );
  }

  Widget _macSidebar() {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sidebarBg = isDark ? const Color(0xFF0B1320) : const Color(0xFF0E1A2B);
    final sideText = isDark ? scheme.onSurface : Colors.white;
    final subText = isDark ? scheme.onSurfaceVariant : const Color(0xFFB7C3D5);

    return Container(
      width: 300,
      color: sidebarBg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isDark ? scheme.primaryContainer : const Color(0xFF1F3B64),
                  ),
                  child: Icon(Icons.apartment_rounded, color: sideText),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Enterprise Suite',
                    style: TextStyle(
                      color: sideText,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isDark ? scheme.surfaceContainerHigh : Colors.white.withOpacity(0.08),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.signedInUser.name,
                    style: TextStyle(color: sideText, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(_roleLabel, style: TextStyle(color: subText)),
                  const SizedBox(height: 4),
                  Text(_scopeText, style: TextStyle(color: subText)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _menus.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, i) {
                final menu = _menus[i];
                final isSelected = _menuIndex == i;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Material(
                    color: isSelected
                        ? (isDark ? scheme.primaryContainer.withOpacity(0.3) : const Color(0xFF1F3B64))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      leading: Icon(menu.icon, color: sideText),
                      title: Text(
                        menu.title,
                        style: TextStyle(color: sideText, fontWeight: FontWeight.w600),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onTap: () => setState(() => _menuIndex = i),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(color: isDark ? scheme.outlineVariant : const Color(0xFF2E3E56), height: 1),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: sideText),
            title: Text('Logout', style: TextStyle(color: sideText)),
            onTap: _logout,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _macTopToolbar() {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Text(
            _menus.isEmpty ? 'Dashboard' : _menus[_safeMenuIndex].title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: scheme.surfaceContainerHighest,
                hintText: 'Search invoice, customer, team',
                hintStyle: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                prefixIcon: Icon(Icons.search_rounded, size: 20, color: scheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _toggleLanguage,
            icon: const Icon(Icons.language_rounded),
          ),
          IconButton(
            onPressed: _toggleTheme,
            icon: const Icon(Icons.brightness_6_rounded),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${widget.signedInUser.name} • $_roleLabel',
              style: TextStyle(fontWeight: FontWeight.w600, color: scheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isPhone = constraints.maxWidth < 780;
        final isDesktop = constraints.maxWidth >= 1200;
        final isMacDesktop = !isPhone && defaultTargetPlatform == TargetPlatform.macOS;

        return Scaffold(
          drawer: isPhone ? _sideMenu(true) : null,
          appBar: isMacDesktop
              ? null
              : AppBar(
                  title: Text(_menus.isEmpty ? 'Dashboard' : _menus[_safeMenuIndex].title),
                  actions: [
                    IconButton(
                      onPressed: _toggleLanguage,
                      icon: const Icon(Icons.language_rounded),
                    ),
                    IconButton(
                      onPressed: _toggleTheme,
                      icon: const Icon(Icons.brightness_6_rounded),
                    ),
                  ],
                ),
          body: SafeArea(
            child: isMacDesktop
                ? Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Row(
                      children: [
                        _macSidebar(),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _macTopToolbar(),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.outlineVariant,
                                      ),
                                    ),
                                    child: _currentScreen(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      if (!isPhone) _sideMenu(false),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(isDesktop ? 20 : 14),
                          child: _currentScreen(),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _OverviewScreen extends StatelessWidget {
  const _OverviewScreen({
    required this.user,
    required this.records,
    required this.totalSales,
    required this.totalCollected,
    required this.totalOutstanding,
  });

  final SalesUser user;
  final List<SalesRecord> records;
  final int totalSales;
  final int totalCollected;
  final int totalOutstanding;

  @override
  Widget build(BuildContext context) {
    final paidCount = records.where((r) => r.status == 'Paid').length;
    final pendingCount = records.where((r) => r.status != 'Paid').length;
    final conversion = records.isEmpty ? 0 : (paidCount / records.length) * 100;

    final sorted = [...records]..sort((a, b) => b.total.compareTo(a.total));
    final recent = sorted.take(5).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF0B4F6C), Color(0xFF117A8B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${user.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sports Product Sales Command Center',
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(label: 'Visible Sales', value: '₹ $totalSales', delta: '+7.8%'),
              _MetricCard(label: 'Collected', value: '₹ $totalCollected', delta: '+5.4%'),
              _MetricCard(label: 'Outstanding', value: '₹ $totalOutstanding', delta: '-2.1%'),
              _MetricCard(label: 'Conversion', value: '${conversion.toStringAsFixed(1)}%', delta: '+1.2%'),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, c) {
              if (c.maxWidth < 980) {
                return Column(
                  children: [
                    _ChartCard(records: records),
                    const SizedBox(height: 12),
                    _InvoiceListCard(recent: recent),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _ChartCard(records: records)),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: _InvoiceListCard(recent: recent)),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Paid invoices: $paidCount   •   Pending invoices: $pendingCount   •   Total visible: ${records.length}',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerScreen extends StatelessWidget {
  const _LedgerScreen({required this.records});

  final List<SalesRecord> records;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sales Ledger', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _ChipTag('Monthly'),
              _ChipTag('With GST'),
              _ChipTag('Outstanding'),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, c) {
              if (c.maxWidth < 920) {
                return Column(
                  children: records
                      .map(
                        (r) => Card(
                          child: ListTile(
                            title: Text('${r.invoiceNo} • ${r.customer}'),
                            subtitle: Text('${r.date}\nTotal ₹ ${r.total} | Balance ₹ ${r.balance}'),
                            isThreeLine: true,
                            trailing: _StatusChip(status: r.status),
                          ),
                        ),
                      )
                      .toList(),
                );
              }
              return Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Invoice')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Customer')),
                      DataColumn(label: Text('Category')),
                      DataColumn(label: Text('Total')),
                      DataColumn(label: Text('Paid')),
                      DataColumn(label: Text('Balance')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: records
                        .map(
                          (r) => DataRow(
                            cells: [
                              DataCell(Text(r.invoiceNo)),
                              DataCell(Text(r.date)),
                              DataCell(Text(r.customer)),
                              DataCell(Text(r.category)),
                              DataCell(Text('₹ ${r.total}')),
                              DataCell(Text('₹ ${r.paid}')),
                              DataCell(Text('₹ ${r.balance}')),
                              DataCell(_StatusChip(status: r.status)),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InvoiceScreen extends StatelessWidget {
  const _InvoiceScreen({required this.records});

  final List<SalesRecord> records;

  @override
  Widget build(BuildContext context) {
    final draftCount = (records.length / 3).round();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Invoice Center', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              const _ActionTile('Create Invoice', Icons.add_card_rounded),
              const _ActionTile('Invoice List', Icons.list_alt_rounded),
              const _ActionTile('Credit Notes', Icons.assignment_return_rounded),
              const _ActionTile('Delivery Challan', Icons.local_shipping_rounded),
              _ActionTile('Draft (${draftCount.toString()})', Icons.edit_note_rounded),
              _ActionTile('Pending (${records.where((r) => r.status != 'Paid').length})',
                  Icons.pending_actions_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamScreen extends StatelessWidget {
  const _TeamScreen({
    required this.visibleUsers,
    required this.records,
  });

  final List<SalesUser> visibleUsers;
  final List<SalesRecord> records;

  @override
  Widget build(BuildContext context) {
    String roleLabel(SalesRole role) {
      switch (role) {
        case SalesRole.admin:
          return 'Admin';
        case SalesRole.supervisor:
          return 'Supervisor';
        case SalesRole.salesManager:
          return 'SalesManager';
      }
    }

    int userSales(String id) =>
        records.where((r) => r.ownerId == id).fold<int>(0, (sum, r) => sum + r.total);
    int userInvoices(String id) => records.where((r) => r.ownerId == id).length;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sales Team Visibility', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: visibleUsers
                .map(
                  (u) => SizedBox(
                    width: 290,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(u.name, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text('Role: ${roleLabel(u.role)}'),
                            const SizedBox(height: 8),
                            Text('Invoices: ${userInvoices(u.id)}'),
                            Text('Sales: ₹ ${userSales(u.id)}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

const List<_PortalProduct> _defaultProducts = <_PortalProduct>[
  _PortalProduct(name: 'Cricket Bat Elite X', sku: 'CRK-1001', price: 5400, category: 'Cricket'),
  _PortalProduct(name: 'Football Pro Grip', sku: 'FTB-3040', price: 1950, category: 'Football'),
  _PortalProduct(name: 'Training Cone Set', sku: 'TRN-9021', price: 780, category: 'Training'),
  _PortalProduct(name: 'Sports Jersey TeamFit', sku: 'JRS-4502', price: 1280, category: 'Teamwear'),
];

class _ProductsScreen extends StatefulWidget {
  const _ProductsScreen({
    required this.refreshToken,
    required this.canManage,
  });

  final int refreshToken;
  final bool canManage;

  @override
  State<_ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<_ProductsScreen> {
  final _localStore = _LocalProductStore();
  bool _isLoading = true;
  List<_PortalProduct> _products = const <_PortalProduct>[];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void didUpdateWidget(covariant _ProductsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    final saved = await _localStore.loadProducts();
    if (!mounted) return;
    setState(() {
      _products = saved.isEmpty ? _defaultProducts : saved;
      _isLoading = false;
    });
  }

  Future<void> _deleteProduct(int index) async {
    final updated = [..._products]..removeAt(index);
    await _localStore.saveProducts(updated);
    if (!mounted) return;
    setState(() => _products = updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product deleted successfully.')),
    );
  }

  Future<void> _editProduct(int index) async {
    final existing = _products[index];
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: existing.name);
    final skuController = TextEditingController(text: existing.sku);
    final priceController = TextEditingController(text: existing.price.toString());
    final categoryController = TextEditingController(text: existing.category);

    final updated = await showDialog<_PortalProduct>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Product'),
          content: SizedBox(
            width: 520,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Product Name'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: skuController,
                    decoration: const InputDecoration(labelText: 'SKU'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      return int.tryParse(v.trim()) == null ? 'Invalid' : null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(context).pop(
                  _PortalProduct(
                    name: nameController.text.trim(),
                    sku: skuController.text.trim(),
                    price: int.parse(priceController.text.trim()),
                    category: categoryController.text.trim(),
                    syncStatus: existing.syncStatus,
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    skuController.dispose();
    priceController.dispose();
    categoryController.dispose();

    if (updated == null) return;

    final newList = [..._products];
    newList[index] = updated;
    await _localStore.saveProducts(newList);
    if (!mounted) return;
    setState(() => _products = newList);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product updated successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Products', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _products.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final p = _products[index];
                  return ListTile(
                    title: Text(p.name),
                    subtitle: Text('SKU: ${p.sku} • ${p.category}'),
                    trailing: widget.canManage
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('₹ ${p.price}'),
                              IconButton(
                                tooltip: 'Edit',
                                onPressed: () => _editProduct(index),
                                icon: const Icon(Icons.edit_rounded),
                              ),
                              IconButton(
                                tooltip: 'Delete',
                                onPressed: () => _deleteProduct(index),
                                icon: const Icon(Icons.delete_outline_rounded),
                              ),
                            ],
                          )
                        : Text('₹ ${p.price}'),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _AddProductScreen extends StatefulWidget {
  const _AddProductScreen({required this.onProductSaved});

  final VoidCallback onProductSaved;

  @override
  State<_AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<_AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _localStore = _LocalProductStore();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final products = await _localStore.loadProducts();
    final currentProducts = products.isEmpty ? [..._defaultProducts] : [...products];
    currentProducts.insert(
      0,
      _PortalProduct(
        name: _nameController.text.trim(),
        sku: _skuController.text.trim(),
        price: int.parse(_priceController.text.trim()),
        category: _categoryController.text.trim(),
        syncStatus: 'Saved locally',
      ),
    );
    await _localStore.saveProducts(currentProducts);

    if (!mounted) return;
    _nameController.clear();
    _skuController.clear();
    _priceController.clear();
    _categoryController.clear();
    setState(() => _isSaving = false);
    widget.onProductSaved();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product added successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Product', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Product',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add product details and save to product catalog.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: 280,
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Product Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                        SizedBox(
                          width: 180,
                          child: TextFormField(
                            controller: _skuController,
                            decoration: const InputDecoration(
                              labelText: 'SKU',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                        SizedBox(
                          width: 180,
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Price',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Required';
                              return int.tryParse(v.trim()) == null ? 'Invalid' : null;
                            },
                          ),
                        ),
                        SizedBox(
                          width: 220,
                          child: TextFormField(
                            controller: _categoryController,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _saveProduct,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_business_rounded),
                      label: Text(_isSaving ? 'Saving...' : 'Add Product'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortalProduct {
  const _PortalProduct({
    required this.name,
    required this.sku,
    required this.price,
    required this.category,
    this.syncStatus = 'Pending sync',
    this.syncMessage,
  });

  final String name;
  final String sku;
  final int price;
  final String category;
  final String syncStatus;
  final String? syncMessage;

  _PortalProduct copyWith({
    String? syncStatus,
    String? syncMessage,
  }) {
    return _PortalProduct(
      name: name,
      sku: sku,
      price: price,
      category: category,
      syncStatus: syncStatus ?? this.syncStatus,
      syncMessage: syncMessage ?? this.syncMessage,
    );
  }

  factory _PortalProduct.fromJson(Map<String, dynamic> json) {
    final priceValue = json['price'];
    return _PortalProduct(
      name: json['name'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      price: priceValue is int ? priceValue : (priceValue is num ? priceValue.toInt() : 0),
      category: json['category'] as String? ?? '',
      syncStatus: json['syncStatus'] as String? ?? 'Saved locally',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'sku': sku,
      'price': price,
      'category': category,
      'syncStatus': syncStatus,
    };
  }
}

class _LocalProductStore {
  Future<List<_PortalProduct>> loadProducts() async {
    final raw = await UserDefaults.getPortalProductsJson();
    if (raw.isEmpty) return const <_PortalProduct>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => _PortalProduct.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveProducts(List<_PortalProduct> products) async {
    final payload = jsonEncode(products.map((p) => p.toJson()).toList());
    await UserDefaults.setPortalProductsJson(payload);
  }
}

enum _PaymentMode { check, onlinePayment }
enum _WithinCreditMode { creditLimit, check, onlinePayment }

class _VendorOrderScreen extends StatefulWidget {
  const _VendorOrderScreen({required this.signedInUser});

  final SalesUser signedInUser;

  @override
  State<_VendorOrderScreen> createState() => _VendorOrderScreenState();
}

class _VendorOrderScreenState extends State<_VendorOrderScreen> {
  final _localStore = _LocalProductStore();
  bool _isLoading = true;
  List<_PortalProduct> _products = const <_PortalProduct>[];
  List<SalesVendor> _vendors = const <SalesVendor>[];
  final Map<String, int> _itemQuantities = <String, int>{};
  final Map<String, int> _freeUnits = <String, int>{};
  final Map<String, List<_VendorCatalogItem>> _catalogByFamilySku = <String, List<_VendorCatalogItem>>{};
  final Map<String, int> _usedCredits = <String, int>{};
  SalesVendor? _selectedVendor;
  _PortalProduct? _selectedFamily;
  _PaymentMode _paymentMode = _PaymentMode.check;
  String? _promoMessage;
  Timer? _promoTimer;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _promoTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    final products = await _localStore.loadProducts();
    final vendors = DemoSalesData.vendorsForSalesManager(widget.signedInUser.id);
    if (!mounted) return;
    setState(() {
      _products = products.isEmpty ? _defaultProducts : products;
      _vendors = vendors;
      _selectedVendor = vendors.isNotEmpty ? vendors.first : null;
      _selectedFamily = _products.isNotEmpty ? _products.first : null;
      for (final family in _products) {
        _catalogByFamilySku[family.sku] = _buildFamilyItems(family);
      }
      for (final vendor in vendors) {
        _usedCredits[vendor.id] = 0;
      }
      _isLoading = false;
    });
  }

  int get _orderTotal {
    var total = 0;
    for (final family in _products) {
      final items = _catalogByFamilySku[family.sku] ?? const <_VendorCatalogItem>[];
      for (final item in items) {
        total += (_itemQuantities[item.id] ?? 0) * item.price;
      }
    }
    return total;
  }

  int _creditAvailable(SalesVendor vendor) {
    final used = _usedCredits[vendor.id] ?? 0;
    return vendor.creditLimit - used;
  }

  List<_VendorCatalogItem> _buildFamilyItems(_PortalProduct family) {
    if (family.sku.startsWith('CRK')) {
      return [
        _VendorCatalogItem(
          id: '${family.sku}_A',
          familySku: family.sku,
          name: '${family.name} - Premium Willow',
          price: family.price,
          offer: const _BuyXGetYOffer(buyQty: 10, freeQty: 1),
        ),
        _VendorCatalogItem(
          id: '${family.sku}_B',
          familySku: family.sku,
          name: '${family.name} - Training Edition',
          price: (family.price * 0.7).toInt(),
        ),
      ];
    }
    if (family.sku.startsWith('FTB')) {
      return [
        _VendorCatalogItem(
          id: '${family.sku}_A',
          familySku: family.sku,
          name: '${family.name} - Match Grade',
          price: family.price,
          offer: const _BuyXGetYOffer(buyQty: 12, freeQty: 2),
        ),
        _VendorCatalogItem(
          id: '${family.sku}_B',
          familySku: family.sku,
          name: '${family.name} - Training Grade',
          price: (family.price * 0.8).toInt(),
        ),
      ];
    }
    return [
      _VendorCatalogItem(
        id: '${family.sku}_A',
        familySku: family.sku,
        name: '${family.name} - Standard',
        price: family.price,
      ),
      _VendorCatalogItem(
        id: '${family.sku}_B',
        familySku: family.sku,
        name: '${family.name} - Bulk Pack',
        price: (family.price * 0.9).toInt(),
        offer: const _BuyXGetYOffer(buyQty: 20, freeQty: 2),
      ),
    ];
  }

  void _changeQty(_VendorCatalogItem item, int delta) {
    final current = _itemQuantities[item.id] ?? 0;
    final next = (current + delta).clamp(0, 999);
    final oldFree = _freeUnits[item.id] ?? 0;
    final newFree = item.offer == null ? 0 : (next ~/ item.offer!.buyQty) * item.offer!.freeQty;

    setState(() {
      _itemQuantities[item.id] = next;
      _freeUnits[item.id] = newFree;
      if (newFree > oldFree) {
        _promoMessage =
            'Congratulations! You got ${newFree - oldFree} free ${item.name} item(s). Added to your count.';
        _promoTimer?.cancel();
        _promoTimer = Timer(const Duration(seconds: 3), () {
          if (!mounted) return;
          setState(() => _promoMessage = null);
        });
      }
    });
  }

  Future<void> _placeOrder() async {
    final vendor = _selectedVendor;
    if (vendor == null) return;
    if (_orderTotal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select product quantity first.')),
      );
      return;
    }

    final available = _creditAvailable(vendor);
    if (_orderTotal <= available) {
      await _handleWithinCreditOrder(vendor);
      return;
    }

    final extraAmount = _orderTotal - available;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) {
        _PaymentMode tempMode = _paymentMode;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Credit Limit Exceeded'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your credit limit is ₹ ${vendor.creditLimit}. '
                    'Pay remaining ₹ $extraAmount now to place this order.',
                  ),
                  const SizedBox(height: 12),
                  RadioListTile<_PaymentMode>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('OnlinePayment'),
                    value: _PaymentMode.onlinePayment,
                    groupValue: tempMode,
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => tempMode = value);
                    },
                  ),
                  RadioListTile<_PaymentMode>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Check'),
                    value: _PaymentMode.check,
                    groupValue: tempMode,
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => tempMode = value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    _paymentMode = tempMode;
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Pay & Punch Order'),
                ),
              ],
            );
          },
        );
      },
    );

    if (proceed != true) return;
    if (!mounted) return;
    setState(() {
      _usedCredits[vendor.id] = vendor.creditLimit;
      _itemQuantities.clear();
      _freeUnits.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Order punched. Paid ₹ $extraAmount via '
          '${_paymentMode == _PaymentMode.check ? 'Check' : 'OnlinePayment'}.',
        ),
      ),
    );
  }

  Future<void> _handleWithinCreditOrder(SalesVendor vendor) async {
    _WithinCreditMode tempMode = _WithinCreditMode.creditLimit;
    int onlinePercent = 15;

    final decision = await showDialog<(_WithinCreditMode, int)>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final slab15 = (_orderTotal * 0.15).round();
            final slab30 = (_orderTotal * 0.30).round();
            final slab100 = _orderTotal;
            return AlertDialog(
              title: const Text('Place Order'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Total: ₹ $_orderTotal'),
                  const SizedBox(height: 8),
                  RadioListTile<_WithinCreditMode>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Credit Limit'),
                    value: _WithinCreditMode.creditLimit,
                    groupValue: tempMode,
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => tempMode = value);
                    },
                  ),
                  RadioListTile<_WithinCreditMode>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Check'),
                    value: _WithinCreditMode.check,
                    groupValue: tempMode,
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => tempMode = value);
                    },
                  ),
                  RadioListTile<_WithinCreditMode>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('OnlinePayment'),
                    value: _WithinCreditMode.onlinePayment,
                    groupValue: tempMode,
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => tempMode = value);
                    },
                  ),
                  if (tempMode == _WithinCreditMode.onlinePayment)
                    DropdownButtonFormField<int>(
                      value: onlinePercent,
                      decoration: const InputDecoration(
                        labelText: 'Online payment slab',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(value: 15, child: Text('15% (₹ $slab15)')),
                        DropdownMenuItem(value: 30, child: Text('30% (₹ $slab30)')),
                        DropdownMenuItem(value: 100, child: Text('100% (₹ $slab100)')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => onlinePercent = value);
                      },
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop((tempMode, onlinePercent)),
                  child: const Text('Place Order'),
                ),
              ],
            );
          },
        );
      },
    );

    if (decision == null) return;
    if (!mounted) return;
    final mode = decision.$1;
    final percent = decision.$2;

    if (mode == _WithinCreditMode.creditLimit) {
      setState(() {
        _usedCredits[vendor.id] = (_usedCredits[vendor.id] ?? 0) + _orderTotal;
        _itemQuantities.clear();
        _freeUnits.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order punched using credit limit for ${vendor.name}.')),
      );
      return;
    }

    if (mode == _WithinCreditMode.check) {
      setState(() {
        _itemQuantities.clear();
        _freeUnits.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order punched with Check payment for ${vendor.name}.')),
      );
      return;
    }

    final onlineAmount = (_orderTotal * (percent / 100)).round();
    final discount =
        percent == 100 ? (_orderTotal * 0.10).round() : (percent > 50 ? (_orderTotal * 0.05).round() : 0);
    final payNow = (onlineAmount - discount).clamp(0, 1 << 30);
    final remaining = _orderTotal - onlineAmount;

    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Summary'),
        content: Text(
          'Selected slab: $percent%\n'
          'Online amount: ₹ $onlineAmount\n'
          'Discount: ₹ $discount\n'
          'Pay now: ₹ $payNow\n'
          'Remaining from credit: ₹ $remaining',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm & Punch'),
          ),
        ],
      ),
    );

    if (proceed != true) return;
    if (!mounted) return;
    setState(() {
      _usedCredits[vendor.id] = (_usedCredits[vendor.id] ?? 0) + remaining;
      _itemQuantities.clear();
      _freeUnits.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Order punched. Paid online ₹ $payNow (discount ₹ $discount). '
          'Remaining ₹ $remaining from credit.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_vendors.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Text(
            'No vendors assigned to this SalesManager.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    final vendor = _selectedVendor!;
    final available = _creditAvailable(vendor);
    final selectedItems =
        _selectedFamily == null ? const <_VendorCatalogItem>[] : _catalogByFamilySku[_selectedFamily!.sku] ?? const <_VendorCatalogItem>[];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vendor Orders', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 280,
                    child: DropdownButtonFormField<SalesVendor>(
                      value: _selectedVendor,
                      decoration: const InputDecoration(
                        labelText: 'Select Vendor',
                        border: OutlineInputBorder(),
                      ),
                      items: _vendors
                          .map(
                            (v) => DropdownMenuItem<SalesVendor>(
                              value: v,
                              child: Text(v.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedVendor = value);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 320,
                    child: DropdownButtonFormField<_PortalProduct>(
                      value: _selectedFamily,
                      decoration: const InputDecoration(
                        labelText: 'Select Product Family',
                        border: OutlineInputBorder(),
                      ),
                      items: _products
                          .map(
                            (p) => DropdownMenuItem<_PortalProduct>(
                              value: p,
                              child: Text(p.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedFamily = value);
                      },
                    ),
                  ),
                  Chip(
                    label: Text('Credit Limit: ₹ ${vendor.creditLimit}'),
                  ),
                  Chip(
                    label: Text('Available Credit: ₹ $available'),
                  ),
                  Chip(
                    label: Text('Order Total: ₹ $_orderTotal'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _promoMessage == null
                ? const SizedBox.shrink()
                : Container(
                    key: ValueKey(_promoMessage),
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade600),
                    ),
                    child: Text(
                      _promoMessage!,
                      style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w600),
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectedItems.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = selectedItems[index];
                final qty = _itemQuantities[item.id] ?? 0;
                final freeQty = _freeUnits[item.id] ?? 0;
                final totalQty = qty + freeQty;
                return ListTile(
                  title: Text(item.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Item SKU: ${item.id} • ₹ ${item.price}'),
                      if (item.offer != null)
                        Text(
                          'Promo: Buy ${item.offer!.buyQty}, Get ${item.offer!.freeQty} Free',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  isThreeLine: item.offer != null,
                  trailing: SizedBox(
                    width: 170,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () => _changeQty(item, -1),
                          icon: const Icon(Icons.remove_circle_outline_rounded),
                        ),
                        Text('$totalQty'),
                        IconButton(
                          onPressed: () => _changeQty(item, 1),
                          icon: const Icon(Icons.add_circle_outline_rounded),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _placeOrder,
            icon: const Icon(Icons.shopping_cart_checkout_rounded),
            label: const Text('Add Cart / Punch Order'),
          ),
        ],
      ),
    );
  }
}

class _VendorCatalogItem {
  const _VendorCatalogItem({
    required this.id,
    required this.familySku,
    required this.name,
    required this.price,
    this.offer,
  });

  final String id;
  final String familySku;
  final String name;
  final int price;
  final _BuyXGetYOffer? offer;
}

class _BuyXGetYOffer {
  const _BuyXGetYOffer({
    required this.buyQty,
    required this.freeQty,
  });

  final int buyQty;
  final int freeQty;
}

class _PaymentsScreen extends StatelessWidget {
  const _PaymentsScreen({required this.records});

  final List<SalesRecord> records;

  @override
  Widget build(BuildContext context) {
    final total = records.fold<int>(0, (s, r) => s + r.total);
    final paid = records.fold<int>(0, (s, r) => s + r.paid);
    final outstanding = total - paid;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payments', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(label: 'Total Billing', value: '₹ $total', delta: '+6.2%'),
              _MetricCard(label: 'Collected', value: '₹ $paid', delta: '+4.7%'),
              _MetricCard(label: 'Outstanding', value: '₹ $outstanding', delta: '-1.1%'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportsScreen extends StatelessWidget {
  const _ReportsScreen({required this.records});

  final List<SalesRecord> records;

  @override
  Widget build(BuildContext context) {
    final categorySales = <String, int>{};
    for (final r in records) {
      categorySales[r.category] = (categorySales[r.category] ?? 0) + r.total;
    }

    final chart = categorySales.entries
        .map((e) => _ChartPoint(e.key, e.value.toDouble()))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reports', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          _ChartCard(records: records),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category Mix', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  _CategoryChart(points: chart),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.records});

  final List<SalesRecord> records;

  @override
  Widget build(BuildContext context) {
    final byDate = <String, int>{};
    for (final r in records) {
      byDate[r.date] = (byDate[r.date] ?? 0) + r.total;
    }
    final points = byDate.entries
        .map((e) => _ChartPoint(e.key.substring(5), e.value.toDouble()))
        .toList()
      ..sort((a, b) => a.label.compareTo(b.label));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sales Trend', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            _SimpleBarChart(points: points),
          ],
        ),
      ),
    );
  }
}

class _InvoiceListCard extends StatelessWidget {
  const _InvoiceListCard({required this.recent});

  final List<SalesRecord> recent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Invoices', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...recent.map(
              (r) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('${r.invoiceNo} • ${r.customer}'),
                subtitle: Text('₹ ${r.total}'),
                trailing: _StatusChip(status: r.status),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleBarChart extends StatelessWidget {
  const _SimpleBarChart({required this.points});

  final List<_ChartPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const Text('No data');
    final max = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: points
            .map(
              (p) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text((p.value / 1000).toStringAsFixed(1)),
                      const SizedBox(height: 4),
                      Container(
                        height: (p.value / max) * 140,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(p.label, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CategoryChart extends StatelessWidget {
  const _CategoryChart({required this.points});

  final List<_ChartPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const Text('No category data');
    final total = points.fold<double>(0, (sum, p) => sum + p.value);
    return Column(
      children: points
          .map(
            (p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(width: 110, child: Text(p.label, overflow: TextOverflow.ellipsis)),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : p.value / total,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(width: 80, child: Text('₹ ${p.value.toInt()}', textAlign: TextAlign.right)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.delta});

  final String label;
  final String value;
  final String delta;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(delta),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile(this.title, this.icon);

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 10),
              Expanded(child: Text(title)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    late final Color color;
    switch (status) {
      case 'Paid':
        color = Colors.green.shade700;
        break;
      case 'Partial':
        color = Colors.orange.shade700;
        break;
      default:
        color = Theme.of(context).colorScheme.error;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _ChipTag extends StatelessWidget {
  const _ChipTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(label),
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.key,
    required this.title,
    required this.icon,
    required this.allowedRoles,
  });

  final String key;
  final String title;
  final IconData icon;
  final Set<SalesRole> allowedRoles;
}

class _ChartPoint {
  const _ChartPoint(this.label, this.value);

  final String label;
  final double value;
}
