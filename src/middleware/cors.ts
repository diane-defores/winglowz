/**
 * CORS (Cross-Origin Resource Sharing) Middleware
 * 
 * Enables cross-origin requests to API endpoints by adding appropriate
 * CORS headers to responses. This is essential for:
 * - Frontend-backend separation in development
 * - Third-party integrations calling our API
 * - Browser-based API clients
 * 
 * Security Note: In production, Access-Control-Allow-Origin should be
 * restricted to specific trusted domains rather than using wildcards.
 * 
 * @module middleware/cors
 */

import type { MiddlewareHandler } from 'astro'

/**
 * CORS header configuration for API responses.
 * 
 * - Allow-Origin: Currently set to localhost for development
 * - Allow-Methods: Standard REST methods plus OPTIONS for preflight
 * - Allow-Headers: Common headers needed for API authentication
 * - Allow-Credentials: Enables cookie-based auth across origins
 */
function getCorsOrigin(): string {
  const origin = import.meta.env.SITE ?? import.meta.env.PUBLIC_SITE_URL;
  if (origin) return origin.replace(/\/$/, '');
  return import.meta.env.DEV ? 'http://localhost:4321' : '';
}

const corsHeaders = {
  'Access-Control-Allow-Origin': getCorsOrigin(),
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, Accept',
  'Access-Control-Allow-Credentials': 'true',
}

/**
 * CORS middleware that handles preflight requests and adds headers to responses.
 * 
 * Preflight handling: Browsers send OPTIONS requests before certain cross-origin
 * requests (those with custom headers or methods other than GET/POST). We must
 * respond with 204 No Content and the CORS headers to allow the actual request.
 * 
 * For actual requests, we pass through to the next handler and then add CORS
 * headers to the response, ensuring cross-origin clients can read the data.
 */
export const corsMiddleware: MiddlewareHandler = async (context, next) => {
  // Handle preflight OPTIONS requests immediately
  if (context.request.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: corsHeaders,
    })
  }

  // Process the actual request through remaining handlers
  const response = await next()

  // Clone response headers and add CORS headers
  const responseHeaders = new Headers(response.headers)
  Object.entries(corsHeaders).forEach(([key, value]) => {
    responseHeaders.set(key, value)
  })

  // Return new response with CORS headers added
  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers: responseHeaders
  })
}