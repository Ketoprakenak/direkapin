import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import {
  dailyReportQuery,
  monthlyReportQuery,
  rangeReportQuery,
  reportResponse,
  weeklyReportQuery,
} from './reports.schemas.js';
import {
  getDailyReport,
  getMonthlyReport,
  getRangeReport,
  getWeeklyReport,
} from './reports.service.js';

export function reportRoutes(app: FastifyInstance) {
  const routes = app.withTypeProvider<ZodTypeProvider>();
  const onRequest = [app.authenticate];
  const response = { 200: reportResponse };

  routes.get(
    '/reports/daily',
    { onRequest, schema: { querystring: dailyReportQuery, response } },
    (request) =>
      getDailyReport(app.prisma, request.userId, request.query.date, request.query.wallet),
  );

  routes.get(
    '/reports/weekly',
    { onRequest, schema: { querystring: weeklyReportQuery, response } },
    (request) =>
      getWeeklyReport(app.prisma, request.userId, request.query.start, request.query.wallet),
  );

  routes.get(
    '/reports/monthly',
    { onRequest, schema: { querystring: monthlyReportQuery, response } },
    (request) =>
      getMonthlyReport(app.prisma, request.userId, request.query.month, request.query.wallet),
  );

  routes.get(
    '/reports/range',
    { onRequest, schema: { querystring: rangeReportQuery, response } },
    (request) =>
      getRangeReport(
        app.prisma,
        request.userId,
        request.query.from,
        request.query.to,
        request.query.wallet,
      ),
  );
}
