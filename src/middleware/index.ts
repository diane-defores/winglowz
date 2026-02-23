import { clerkMiddleware } from '@clerk/astro/server';
import { sequence } from 'astro:middleware';
import type { MiddlewareHandler, APIContext, MiddlewareNext } from 'astro';
import { corsMiddleware } from './cors';
import { i18nMiddleware } from './i18n';

const appMiddleware: MiddlewareHandler = async (context: APIContext, next: MiddlewareNext) => {
  const url = new URL(context.request.url);

  if (url.pathname.startsWith('/api/')) {
    return corsMiddleware(context, next);
  }

  return i18nMiddleware(context, next);
};

export const onRequest = sequence(
  clerkMiddleware(),
  appMiddleware,
);
