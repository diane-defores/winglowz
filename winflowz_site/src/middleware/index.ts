import { clerkMiddleware } from '@clerk/astro/server';
import { sequence } from 'astro:middleware';
import type { APIContext, MiddlewareHandler, MiddlewareNext } from 'astro';
import { corsMiddleware } from './cors';
import { shouldBypassClerkMiddleware } from './authRouting';
import { i18nMiddleware } from './i18n';

const appMiddleware = async (context: APIContext, next: MiddlewareNext): Promise<Response> => {
  const url = new URL(context.request.url);

  if (url.pathname.startsWith('/api/')) {
    return corsMiddleware(context, next) as Promise<Response>;
  }

  return i18nMiddleware(context, next) as Promise<Response>;
};

let clerkAwareMiddleware: MiddlewareHandler | null = null;

function getClerkAwareMiddleware(): MiddlewareHandler {
  clerkAwareMiddleware ??= sequence(
    clerkMiddleware(),
    appMiddleware,
  );

  return clerkAwareMiddleware;
}

export const onRequest: MiddlewareHandler = (context, next) => {
  const url = new URL(context.request.url);

  if (shouldBypassClerkMiddleware(url.pathname)) {
    return appMiddleware(context, next);
  }

  return getClerkAwareMiddleware()(context, next);
};
