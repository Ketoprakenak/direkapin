-- AlterTable
ALTER TABLE "transfers" ADD COLUMN     "feeTransactionId" UUID;

-- CreateIndex
CREATE UNIQUE INDEX "transfers_feeTransactionId_key" ON "transfers"("feeTransactionId");

-- AddForeignKey
ALTER TABLE "transfers" ADD CONSTRAINT "transfers_feeTransactionId_fkey" FOREIGN KEY ("feeTransactionId") REFERENCES "transactions"("id") ON DELETE SET NULL ON UPDATE CASCADE;

