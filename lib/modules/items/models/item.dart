import 'package:flutter/material.dart';

import '../../../config/theme/app_theme.dart';

/// A sellable product or service in the catalogue.
///
/// NOTE: [demo] serves as placeholder data until the backend is wired (see
/// the TODO in `repository/item_repository.dart`).
class Item {
  const Item({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.unit = 'pcs',
    this.icon = Icons.shopping_bag_rounded,
    this.color = AppColors.primary,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String unit;
  final IconData icon;
  final Color color;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: '${json['id'] ?? ''}',
    name: json['name'] as String? ?? '',
    category: json['category'] as String? ?? 'General',
    price: (json['price'] as num?)?.toDouble() ?? 0,
    stock: (json['stock'] as num?)?.toInt() ?? 0,
    unit: json['unit'] as String? ?? 'pcs',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'price': price,
    'stock': stock,
    'unit': unit,
  };

  static const List<Item> demo = [
    Item(
      id: 'ITM-001',
      name: 'Office Chair',
      category: 'Furniture',
      price: 120,
      stock: 24,
      icon: Icons.chair_rounded,
      color: Color(0xFF1D4ED8),
    ),
    Item(
      id: 'ITM-002',
      name: 'Wireless Keyboard',
      category: 'Electronics',
      price: 45.5,
      stock: 60,
      icon: Icons.keyboard_rounded,
      color: Color(0xFF059669),
    ),
    Item(
      id: 'ITM-003',
      name: 'USB-C Hub',
      category: 'Electronics',
      price: 32,
      stock: 120,
      icon: Icons.usb_rounded,
      color: Color(0xFFFBBF24),
    ),
    Item(
      id: 'ITM-004',
      name: 'Desk Lamp',
      category: 'Furniture',
      price: 28.75,
      stock: 40,
      icon: Icons.light_mode_rounded,
      color: Color(0xFF7C3AED),
    ),
    Item(
      id: 'ITM-005',
      name: 'Steel Filing Cabinet',
      category: 'Furniture',
      price: 210,
      stock: 8,
      icon: Icons.inventory_2_rounded,
      color: Color(0xFF3B82F6),
    ),
  ];
}
