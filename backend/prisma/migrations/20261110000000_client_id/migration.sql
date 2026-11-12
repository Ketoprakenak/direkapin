-- AlterTable
ALTER TABLE "transactions" ADD COLUMN     "clientId" UUID;

-- AlterTable
ALTER TABLE "transfers" ADD COLUMN     "clientId" UUID;

-- CreateIndex
CREATE UNIQUE INDEX "transactions_userId_clientId_key" ON "transactions"("userId", "clientId");

-- CreateIndex
CREATE UNIQUE INDEX "transfers_userId_clientId_key" ON "transfers"("userId", "clientId");

