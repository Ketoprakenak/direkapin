import { mkdir, readFile, rm, writeFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import type { FastifyBaseLogger } from 'fastify';

// Path relatif selalu dibuat server dari userId dan attachmentId, tidak pernah dari nama file client.

export async function writeUpload(uploadDir: string, relativePath: string, data: Buffer) {
  const path = join(uploadDir, relativePath);
  await mkdir(dirname(path), { recursive: true });
  await writeFile(path, data);
}

export function readUpload(uploadDir: string, relativePath: string) {
  return readFile(join(uploadDir, relativePath));
}

/** Data di DB sudah hilang saat ini dipanggil, jadi kegagalan hanya di-log. */
export async function removeUploads(
  uploadDir: string,
  relativePaths: string[],
  log: FastifyBaseLogger,
) {
  await Promise.all(
    relativePaths.map((path) =>
      rm(join(uploadDir, path), { force: true }).catch((err: unknown) =>
        log.error({ err, path }, 'gagal menghapus file foto'),
      ),
    ),
  );
}
