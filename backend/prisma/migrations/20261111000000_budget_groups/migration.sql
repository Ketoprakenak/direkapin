-- Budget multi kategori (D-60). Tabel budgets belum pernah dipakai (kosong), jadi kolom NOT NULL aman.
-- DropForeignKey
ALTER TABLE "budgets" DROP CONSTRAINT "budgets_categoryId_fkey";

-- DropIndex
DROP INDEX "budgets_userId_categoryId_month_key";

-- AlterTable
ALTER TABLE "budgets" DROP COLUMN "categoryId",
DROP COLUMN "month",
ADD COLUMN     "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "endMonth" VARCHAR(7),
ADD COLUMN     "name" VARCHAR(40) NOT NULL,
ADD COLUMN     "startMonth" VARCHAR(7) NOT NULL;

-- CreateTable
CREATE TABLE "budget_categories" (
    "budgetId" UUID NOT NULL,
    "categoryId" UUID NOT NULL,

    CONSTRAINT "budget_categories_pkey" PRIMARY KEY ("budgetId","categoryId")
);

-- CreateIndex
CREATE INDEX "budgets_userId_startMonth_idx" ON "budgets"("userId", "startMonth");

-- AddForeignKey
ALTER TABLE "budget_categories" ADD CONSTRAINT "budget_categories_budgetId_fkey" FOREIGN KEY ("budgetId") REFERENCES "budgets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "budget_categories" ADD CONSTRAINT "budget_categories_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "categories"("id") ON DELETE CASCADE ON UPDATE CASCADE;

