import 'package:flutter/material.dart';

import '../../../routing/app_routes.dart';

/// Data-driven sidebar menu.
///
/// Entry shape: `{ name, is_visible, route, icon, selected_icon }`.
const Map<String, dynamic> sidebarMenu = {
  'Dashboard': {
    'name': 'Dashboard',
    'is_visible': true,
    'route': AppRoutes.dashboard,
    'icon': Icons.dashboard_outlined,
    'selected_icon': Icons.dashboard_rounded,
  },
  'Items': {
    'name': 'Items',
    'is_visible': true,
    'route': AppRoutes.items,
    'icon': Icons.inventory_2_outlined,
    'selected_icon': Icons.inventory_2_rounded,
  },
  'Accounting Masters': {
    'name': 'Accounting Masters',
    'is_visible': true,
    'route': AppRoutes.accountingMasters,
    'icon': Icons.account_balance_wallet_outlined,
    'selected_icon': Icons.account_balance_wallet_rounded,
  },
  'Inventory Masters': {
    'name': 'Inventory Masters',
    'is_visible': true,
    'route': AppRoutes.inventoryMasters,
    'icon': Icons.warehouse_outlined,
    'selected_icon': Icons.warehouse_rounded,
  },
  'Organisational Masters': {
    'name': 'Organisational Masters',
    'is_visible': true,
    'route': AppRoutes.organisationalMasters,
    'icon': Icons.apartment_outlined,
    'selected_icon': Icons.apartment_rounded,
  },
  'Invoices': {
    'name': 'Invoices',
    'is_visible': true,
    'route': AppRoutes.invoices,
    'icon': Icons.receipt_long_outlined,
    'selected_icon': Icons.receipt_long_rounded,
  },
  'Payments': {
    'name': 'Payments',
    'is_visible': true,
    'route': AppRoutes.payments,
    'icon': Icons.payments_outlined,
    'selected_icon': Icons.payments_rounded,
  },
  'Customers': {
    'name': 'Customers',
    'is_visible': true,
    'route': AppRoutes.customers,
    'icon': Icons.people_outline,
    'selected_icon': Icons.people_rounded,
  },
  'Reports': {
    'name': 'Reports',
    'is_visible': true,
    'route': AppRoutes.reports,
    'icon': Icons.bar_chart_outlined,
    'selected_icon': Icons.bar_chart_rounded,
  },
  'Settings': {
    'name': 'Settings',
    'is_visible': true,
    'route': AppRoutes.settings,
    'icon': Icons.settings_outlined,
    'selected_icon': Icons.settings_rounded,
  },
};

/// Ordered, visible sidebar entries (respecting `is_visible`).
List<Map<String, dynamic>> sidebarMenuItems() => [
      for (final entry in sidebarMenu.values)
        if (entry['is_visible'] == true) entry as Map<String, dynamic>,
    ];
