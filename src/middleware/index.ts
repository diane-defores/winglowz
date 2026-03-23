import { clerkMiddleware } from '@clerk/astro/server';
import { sequence } from 'astro:middleware';
import type { APIContext, MiddlewareHandler, MiddlewareNext } from 'astro';
import { corsMiddleware } from './cors';
import { i18nMiddleware } from './i18n';

const appMiddleware: MiddlewareHandler = async (context: APIContext, next: MiddlewareNext) => {
  const url = new URL(context.request.url);

  if (url.pathname.startsWith('/api/')) {
    return corsMiddleware(context, next) as any;
  }

  return i18nMiddleware(context, next) as any;
};

export const onRequest = sequence(
  clerkMiddleware(),
  appMiddleware,
);
