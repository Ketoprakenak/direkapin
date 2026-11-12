import type { FastifyInstance } from 'fastify';
import type { ZodTypeProvider } from 'fastify-type-provider-zod';
import {
  calendarQuery,
  calendarResponse,
  dailyNoteBody,
  dailyNoteResponse,
  dayParams,
  dayResponse,
} from './calendar.schemas.js';
import { getCalendar, getDay, putDailyNote } from './calendar.service.js';

export function calendarRoutes(app: FastifyInstance) {
  const routes = app.withTypeProvider<ZodTypeProvider>();
  const onRequest = [app.authenticate];

  routes.get(
    '/calendar',
    { onRequest, schema: { querystring: calendarQuery, response: { 200: calendarResponse } } },
    (request) => getCalendar(app.prisma, request.userId, request.query.month),
  );

  routes.get(
    '/days/:date',
    { onRequest, schema: { params: dayParams, response: { 200: dayResponse } } },
    (request) => getDay(app.prisma, request.userId, request.params.date),
  );

  routes.put(
    '/days/:date/note',
    {
      onRequest,
      schema: { params: dayParams, body: dailyNoteBody, response: { 200: dailyNoteResponse } },
    },
    (request) => putDailyNote(app.prisma, request.userId, request.params.date, request.body),
  );
}
