-- CreateTable
CREATE TABLE "receivables" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "title" VARCHAR(60) NOT NULL,
    "date" DATE NOT NULL,
    "note" VARCHAR(1000),
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "receivables_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "receivable_debtors" (
    "id" UUID NOT NULL,
    "receivableId" UUID NOT NULL,
    "name" VARCHAR(30) NOT NULL,
    "amount" BIGINT NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "receivable_debtors_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "receivable_payments" (
    "id" UUID NOT NULL,
    "debtorId" UUID NOT NULL,
    "transactionId" UUID NOT NULL,

    CONSTRAINT "receivable_payments_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "receivables_userId_date_idx" ON "receivables"("userId", "date");

-- CreateIndex
CREATE INDEX "receivable_debtors_receivableId_idx" ON "receivable_debtors"("receivableId");

-- CreateIndex
CREATE UNIQUE INDEX "receivable_payments_transactionId_key" ON "receivable_payments"("transactionId");

-- CreateIndex
CREATE INDEX "receivable_payments_debtorId_idx" ON "receivable_payments"("debtorId");

-- AddForeignKey
ALTER TABLE "receivables" ADD CONSTRAINT "receivables_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "receivable_debtors" ADD CONSTRAINT "receivable_debtors_receivableId_fkey" FOREIGN KEY ("receivableId") REFERENCES "receivables"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "receivable_payments" ADD CONSTRAINT "receivable_payments_debtorId_fkey" FOREIGN KEY ("debtorId") REFERENCES "receivable_debtors"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "receivable_payments" ADD CONSTRAINT "receivable_payments_transactionId_fkey" FOREIGN KEY ("transactionId") REFERENCES "transactions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

