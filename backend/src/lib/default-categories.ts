import type { TxType } from '@prisma/client';

// Sumber: docs/DESIGN.md. Disalin per user saat registrasi (D-09, D-20).
export const DEFAULT_CATEGORIES: { name: string; type: TxType; icon: string; color: string }[] = [
  { name: 'Makan', type: 'EXPENSE', icon: 'restaurant_rounded', color: '#F97316' },
  { name: 'Transport', type: 'EXPENSE', icon: 'directions_bus_rounded', color: '#3B82F6' },
  { name: 'Kuliah', type: 'EXPENSE', icon: 'school_rounded', color: '#8B5CF6' },
  { name: 'Hiburan', type: 'EXPENSE', icon: 'sports_esports_rounded', color: '#EC4899' },
  { name: 'Belanja', type: 'EXPENSE', icon: 'shopping_bag_rounded', color: '#EAB308' },
  { name: 'Tagihan', type: 'EXPENSE', icon: 'receipt_long_rounded', color: '#EF4444' },
  { name: 'Lainnya', type: 'EXPENSE', icon: 'more_horiz_rounded', color: '#78716C' },
  { name: 'Gaji / Uang saku', type: 'INCOME', icon: 'payments_rounded', color: '#22C55E' },
  { name: 'Lainnya', type: 'INCOME', icon: 'more_horiz_rounded', color: '#14B8A6' },
];
