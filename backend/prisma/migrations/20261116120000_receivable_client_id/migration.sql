-- AlterTable
ALTER TABLE "receivables" ADD COLUMN     "clientId" UUID;

-- CreateIndex
CREATE UNIQUE INDEX "receivables_userId_clientId_key" ON "receivables"("userId", "clientId");
