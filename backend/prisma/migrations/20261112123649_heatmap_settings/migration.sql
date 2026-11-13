-- CreateEnum
CREATE TYPE "HeatmapMode" AS ENUM ('AUTO', 'FIXED');

-- AlterTable
ALTER TABLE "users" ADD COLUMN     "heatmapMode" "HeatmapMode" NOT NULL DEFAULT 'AUTO',
ADD COLUMN     "heatmapThresholds" BIGINT[] DEFAULT ARRAY[50000, 100000, 200000]::BIGINT[];
