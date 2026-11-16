-- AlterEnum
ALTER TYPE "WalletType" ADD VALUE 'SAVINGS';

-- AlterTable
ALTER TABLE "wallets" ADD COLUMN     "targetAmount" BIGINT;

