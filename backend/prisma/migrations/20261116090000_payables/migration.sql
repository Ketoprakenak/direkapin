-- CreateEnum
CREATE TYPE "ReceivableDirection" AS ENUM ('RECEIVABLE', 'PAYABLE');

-- AlterTable
ALTER TABLE "receivables" ADD COLUMN     "direction" "ReceivableDirection" NOT NULL DEFAULT 'RECEIVABLE',
ADD COLUMN     "loanTransactionId" UUID;

-- CreateIndex
CREATE UNIQUE INDEX "receivables_loanTransactionId_key" ON "receivables"("loanTransactionId");

-- AddForeignKey
ALTER TABLE "receivables" ADD CONSTRAINT "receivables_loanTransactionId_fkey" FOREIGN KEY ("loanTransactionId") REFERENCES "transactions"("id") ON DELETE SET NULL ON UPDATE CASCADE;
