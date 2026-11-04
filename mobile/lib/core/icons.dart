import 'package:flutter/material.dart';

/// Nilai `icon` di database = nama ikon tanpa `Icons.` (docs/DESIGN.md).
const _icons = <String, IconData>{
  'restaurant_rounded': Icons.restaurant_rounded,
  'directions_bus_rounded': Icons.directions_bus_rounded,
  'school_rounded': Icons.school_rounded,
  'sports_esports_rounded': Icons.sports_esports_rounded,
  'shopping_bag_rounded': Icons.shopping_bag_rounded,
  'receipt_long_rounded': Icons.receipt_long_rounded,
  'more_horiz_rounded': Icons.more_horiz_rounded,
  'payments_rounded': Icons.payments_rounded,
  'account_balance_wallet_rounded': Icons.account_balance_wallet_rounded,
  'account_balance_rounded': Icons.account_balance_rounded,
  'phone_iphone_rounded': Icons.phone_iphone_rounded,
  'local_cafe_rounded': Icons.local_cafe_rounded,
  'home_rounded': Icons.home_rounded,
  'favorite_rounded': Icons.favorite_rounded,
  'fitness_center_rounded': Icons.fitness_center_rounded,
  'flight_rounded': Icons.flight_rounded,
  'pets_rounded': Icons.pets_rounded,
  'card_giftcard_rounded': Icons.card_giftcard_rounded,
  'savings_rounded': Icons.savings_rounded,
};

IconData iconFor(String name) => _icons[name] ?? Icons.more_horiz_rounded;

/// Pilihan ikon saat membuat kategori custom.
const categoryIconNames = [
  'restaurant_rounded',
  'local_cafe_rounded',
  'directions_bus_rounded',
  'school_rounded',
  'sports_esports_rounded',
  'shopping_bag_rounded',
  'receipt_long_rounded',
  'home_rounded',
  'favorite_rounded',
  'fitness_center_rounded',
  'flight_rounded',
  'pets_rounded',
  'card_giftcard_rounded',
  'savings_rounded',
  'payments_rounded',
  'more_horiz_rounded',
];
