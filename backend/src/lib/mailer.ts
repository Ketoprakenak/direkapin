import type { FastifyBaseLogger } from 'fastify';
import nodemailer from 'nodemailer';
import type { Config } from '../config.js';

export type SendMail = (to: string, subject: string, text: string) => Promise<void>;

/** SMTP dari env (Gmail: smtp.gmail.com, 465, App Password). Tanpa SMTP (hanya dev/test):
 *  email ditulis ke log, termasuk isinya, supaya alur bisa dicoba tanpa akun email. */
export function createMailer(config: Config, log: FastifyBaseLogger): SendMail {
  if (!config.SMTP_HOST || !config.SMTP_USER || !config.SMTP_PASS) {
    return async (to, subject, text) => {
      log.warn({ to, subject, text }, 'SMTP belum diatur, email hanya ditulis ke log');
    };
  }
  const transport = nodemailer.createTransport({
    host: config.SMTP_HOST,
    port: config.SMTP_PORT,
    secure: config.SMTP_PORT === 465,
    auth: { user: config.SMTP_USER, pass: config.SMTP_PASS },
  });
  return async (to, subject, text) => {
    await transport.sendMail({
      from: config.SMTP_FROM ?? `Direkapin <${config.SMTP_USER}>`,
      to,
      subject,
      text,
    });
  };
}
