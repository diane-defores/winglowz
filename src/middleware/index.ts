import { clerkMiddleware } from '@clerk/astro/server';
import { sequence } from 'astro:middleware';
import type { APIContext, MiddlewareNext } from 'astro';
import { corsMiddleware } from './cors';
import { i18nMiddleware } from './i18n';

const appMiddleware = async (context: APIContext, next: MiddlewareNext): Promise<Response> => {
  const url = new URL(context.request.url);

  if (url.pathname.startsWith('/api/')) {
    return corsMiddleware(context, next) as Promise<Response>;
  }

  return i18nMiddleware(context, next) as Promise<Response>;
};

export const onRequest = sequence(
  clerkMiddleware(),
  appMiddleware,
);
