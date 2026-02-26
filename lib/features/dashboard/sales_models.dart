enum SalesRole { admin, supervisor, salesManager }

class SalesUser {
  const SalesUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.managerId,
  });

  final String id;
  final String name;
  final String email;
  final SalesRole role;
  final String? managerId;
}

class SalesRecord {
  const SalesRecord({
    required this.invoiceNo,
    required this.date,
    required this.customer,
    required this.total,
    required this.paid,
    required this.ownerId,
    required this.category,
  });

  final String invoiceNo;
  final String date;
  final String customer;
  final int total;
  final int paid;
  final String ownerId;
  final String category;

  int get balance => total - paid;

  String get status {
    if (paid >= total) return 'Paid';
    if (paid == 0) return 'Pending';
    return 'Partial';
  }
}

class SalesVendor {
  const SalesVendor({
    required this.id,
    required this.name,
    required this.salesManagerId,
    required this.creditLimit,
  });

  final String id;
  final String name;
  final String salesManagerId;
  final int creditLimit;
}

class DemoSalesData {
  const DemoSalesData._();

  static const users = <SalesUser>[
    SalesUser(
      id: 'u_admin_1',
      name: 'Arun Raj',
      email: 'admin@company.com',
      role: SalesRole.admin,
    ),
    SalesUser(
      id: 'u_sup_1',
      name: 'Maya Singh',
      email: 'supervisor1@company.com',
      role: SalesRole.supervisor,
      managerId: 'u_admin_1',
    ),
    SalesUser(
      id: 'u_sup_2',
      name: 'Rohit Das',
      email: 'supervisor2@company.com',
      role: SalesRole.supervisor,
      managerId: 'u_admin_1',
    ),
    SalesUser(
      id: 'u_sm_1',
      name: 'Kiran Patel',
      email: 'sales1@company.com',
      role: SalesRole.salesManager,
      managerId: 'u_sup_1',
    ),
    SalesUser(
      id: 'u_sm_2',
      name: 'Nisha Roy',
      email: 'sales2@company.com',
      role: SalesRole.salesManager,
      managerId: 'u_sup_1',
    ),
    SalesUser(
      id: 'u_sm_3',
      name: 'Deepak Jain',
      email: 'sales3@company.com',
      role: SalesRole.salesManager,
      managerId: 'u_sup_2',
    ),
    SalesUser(
      id: 'u_sm_4',
      name: 'Suman Verma',
      email: 'sales4@company.com',
      role: SalesRole.salesManager,
      managerId: 'u_sup_2',
    ),
  ];

  static const records = <SalesRecord>[
    SalesRecord(
      invoiceNo: 'INV-3001',
      date: '2026-02-20',
      customer: 'Ace Sports Mart',
      total: 84500,
      paid: 84500,
      ownerId: 'u_sm_1',
      category: 'Footwear',
    ),
    SalesRecord(
      invoiceNo: 'INV-3002',
      date: '2026-02-20',
      customer: 'Pro Cricket House',
      total: 128000,
      paid: 65000,
      ownerId: 'u_sm_2',
      category: 'Cricket',
    ),
    SalesRecord(
      invoiceNo: 'INV-3003',
      date: '2026-02-21',
      customer: 'Fitline Hub',
      total: 56200,
      paid: 0,
      ownerId: 'u_sm_3',
      category: 'Fitness',
    ),
    SalesRecord(
      invoiceNo: 'INV-3004',
      date: '2026-02-21',
      customer: 'Victory Sports',
      total: 91200,
      paid: 70000,
      ownerId: 'u_sm_4',
      category: 'Training',
    ),
    SalesRecord(
      invoiceNo: 'INV-3005',
      date: '2026-02-22',
      customer: 'Champion Arena',
      total: 44500,
      paid: 44500,
      ownerId: 'u_sm_1',
      category: 'Accessories',
    ),
    SalesRecord(
      invoiceNo: 'INV-3006',
      date: '2026-02-23',
      customer: 'Goal Post Retail',
      total: 73600,
      paid: 30000,
      ownerId: 'u_sm_2',
      category: 'Football',
    ),
    SalesRecord(
      invoiceNo: 'INV-3007',
      date: '2026-02-23',
      customer: 'Athlete Point',
      total: 118400,
      paid: 118400,
      ownerId: 'u_sm_3',
      category: 'Running',
    ),
    SalesRecord(
      invoiceNo: 'INV-3008',
      date: '2026-02-24',
      customer: 'Arena Sports Club',
      total: 69200,
      paid: 22000,
      ownerId: 'u_sm_4',
      category: 'Teamwear',
    ),
  ];

  static const vendors = <SalesVendor>[
    SalesVendor(
      id: 'v_101',
      name: 'Ace Sports Distributors',
      salesManagerId: 'u_sm_1',
      creditLimit: 100000,
    ),
    SalesVendor(
      id: 'v_102',
      name: 'Fitline Wholesale',
      salesManagerId: 'u_sm_1',
      creditLimit: 120000,
    ),
    SalesVendor(
      id: 'v_201',
      name: 'Prime Athletic Vendors',
      salesManagerId: 'u_sm_2',
      creditLimit: 100000,
    ),
    SalesVendor(
      id: 'v_301',
      name: 'Victory Sports Traders',
      salesManagerId: 'u_sm_3',
      creditLimit: 150000,
    ),
    SalesVendor(
      id: 'v_401',
      name: 'Champion Retail Network',
      salesManagerId: 'u_sm_4',
      creditLimit: 100000,
    ),
  ];

  static SalesUser resolveUserForLogin({
    required String email,
    required SalesRole role,
  }) {
    final normalized = email.trim().toLowerCase();
    for (final user in users) {
      if (user.role == role && user.email.toLowerCase() == normalized) {
        return user;
      }
    }
    return users.firstWhere((u) => u.role == role);
  }

  static List<SalesUser> usersByRole(SalesRole role) {
    return users.where((u) => u.role == role).toList();
  }

  static List<SalesVendor> vendorsForSalesManager(String salesManagerId) {
    return vendors.where((v) => v.salesManagerId == salesManagerId).toList();
  }
}

class SalesVisibility {
  const SalesVisibility._();

  static Set<String> visibleUserIds(SalesUser signedInUser, List<SalesUser> allUsers) {
    if (signedInUser.role == SalesRole.admin) {
      return allUsers.map((u) => u.id).toSet();
    }

    if (signedInUser.role == SalesRole.salesManager) {
      return {signedInUser.id};
    }

    final ids = <String>{signedInUser.id};
    final queue = <String>[signedInUser.id];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      final children = allUsers.where((u) => u.managerId == current).map((u) => u.id).toList();
      for (final child in children) {
        if (ids.add(child)) {
          queue.add(child);
        }
      }
    }
    return ids;
  }

  static List<SalesRecord> visibleRecords(SalesUser signedInUser) {
    final ids = visibleUserIds(signedInUser, DemoSalesData.users);
    return DemoSalesData.records.where((r) => ids.contains(r.ownerId)).toList();
  }
}
