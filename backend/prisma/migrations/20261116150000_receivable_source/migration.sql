-- AlterTable
ALTER TABLE "receivables" ADD COLUMN     "sourceTransactionId" UUID;

-- CreateIndex
CREATE UNIQUE INDEX "receivables_sourceTransactionId_key" ON "receivables"("sourceTransactionId");

-- AddForeignKey
ALTER TABLE "receivables" ADD CONSTRAINT "receivables_sourceTransactionId_fkey" FOREIGN KEY ("sourceTransactionId") REFERENCES "transactions"("id") ON DELETE SET NULL ON UPDATE CASCADE;
