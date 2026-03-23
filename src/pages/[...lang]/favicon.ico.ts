export const prerender = true;

import type { APIRoute } from "astro";
import sharp from "sharp";
import { fileURLToPath } from 'url';
import path from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const getStaticPaths = () => {
  return [
    { params: { lang: 'fr' } },
    { params: { lang: 'en' } },
  ];
};

export const GET: APIRoute = async () => {
  try {
    const faviconBuffer = await sharp(path.join(__dirname, '../../../../public/images/WinFlowz.png'))
      .resize(32, 32)
      .png()
      .toBuffer();

    return new Response(new Uint8Array(faviconBuffer), {
      headers: {
        'Content-Type': 'image/x-icon'
      }
    });
  } catch (error) {
    console.error('Error generating favicon:', error);
    return new Response('Error generating favicon', { status: 500 });
  }
};
