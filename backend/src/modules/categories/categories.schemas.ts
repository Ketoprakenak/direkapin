import { z } from 'zod';
import { hexColor, iconName, shortName } from '../../lib/schemas.js';

export const txType = z.enum(['INCOME', 'EXPENSE'], { error: 'Tipe tidak valid' });

export const listCategoriesQuery = z.object({
  type: txType.optional(),
  includeHidden: z.stringbool().default(false),
});

export const createCategoryBody = z.object({
  name: shortName,
  type: txType,
  icon: iconName,
  color: hexColor,
});

export const updateCategoryBody = z.object({
  name: shortName.optional(),
  icon: iconName.optional(),
  color: hexColor.optional(),
  isHidden: z.boolean().optional(),
  sortOrder: z.number().int().optional(),
});

export const categoryResponse = z.object({
  id: z.uuid(),
  name: z.string(),
  type: txType,
  icon: z.string(),
  color: z.string(),
  isDefault: z.boolean(),
  isHidden: z.boolean(),
  sortOrder: z.number().int(),
});

export const categoryListResponse = z.object({ items: z.array(categoryResponse) });

export const categoryRef = z.object({
  id: z.uuid(),
  name: z.string(),
  icon: z.string(),
  color: z.string(),
});
