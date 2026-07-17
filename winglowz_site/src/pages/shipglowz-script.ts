export const prerender = true;

import type { APIRoute } from 'astro';
import installer from '../generated/shipglowz-installer.sh?raw';

export const GET: APIRoute = () => {
  return new Response(installer, {
    headers: {
      'Cache-Control': 'public, max-age=300, s-maxage=300',
      'Content-Type': 'text/plain; charset=utf-8',
    },
  });
};
