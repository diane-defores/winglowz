import { defineConfig } from "astro/config";
import tailwind from "@astrojs/tailwind";
import sitemap from "@astrojs/sitemap";
import starlight from '@astrojs/starlight';
import vercel from '@astrojs/vercel';
import react from '@astrojs/react';
import clerk from '@clerk/astro';
import icon from "astro-icon";
import { fileURLToPath } from 'url';
import path from 'path';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export default defineConfig({
  site: "https://winflowz.com",
  output: "server",
  adapter: vercel({
    webAnalytics: {
      enabled: true,
    },
    functionPerRoute: false,
    edgeMiddleware: false
  }),
  server: {
    host: true,
    port: parseInt(process.env.PORT) || 3011
  },
  build: {
    inlineStylesheets: "auto"
  },
  vite: {
    resolve: {
      alias: {
        '~': path.resolve(__dirname, './src'),
        '@': path.resolve(__dirname, './src'),
        '@components': path.resolve(__dirname, './src/components'),
        '@layouts': path.resolve(__dirname, './src/layouts'),
        '@lib': path.resolve(__dirname, './src/lib'),
        '@utils': path.resolve(__dirname, './src/utils'),
        '@styles': path.resolve(__dirname, './src/assets/styles'),
        '@scripts': path.resolve(__dirname, './src/assets/scripts'),
        '@assets': path.resolve(__dirname, './src/assets'),
        '@images': path.resolve(__dirname, './src/assets/images'),
        'nanoid/non-secure': 'nanoid/non-secure/index.js'
      },
      dedupe: ['react', 'react-dom'],
    },
    ssr: {
      noExternal: ['@astrojs/starlight/*']
    },
    cacheDir: '.vite'
  },
  cacheDir: '.astro',
  integrations: [
    starlight({
      title: 'WinFlowz Docs',
      head: [
        { tag: 'link', attrs: { rel: 'preconnect', href: 'https://fonts.googleapis.com' } },
        { tag: 'link', attrs: { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' } },
        { tag: 'link', attrs: { href: 'https://fonts.googleapis.com/css2?family=Audiowide&family=Manrope:wght@200..800&family=DM+Sans:opsz,wght@9..40,100..1000&family=Space+Grotesk:wght@300..700&display=swap', rel: 'stylesheet' } },
      ],
      customCss: [
        './src/assets/styles/global.css',
        './src/assets/styles/starlight.css'
      ],
      components: {
        SkipLink: '@components/overrides/EmptySkipLink.astro'
      },
      logo: {
        src: './src/assets/images/WinFlowz.png',
        replacesTitle: true
      },
      defaultLocale: 'en',
      locales: {
        en: {
          label: 'English',
          lang: 'en'
        },
        fr: {
          label: 'Français',
          lang: 'fr',
          pathPrefix: '/fr'
        }
      },
      disable404Route: true,
      sidebar: [
        {
          label: 'Welcome',
          translations: {
            fr: 'Bienvenue'
          },
          autogenerate: {
            directory: 'Welcome'
          }
        },
        {
          label: 'Formations',
          translations: {
            fr: 'Formations'
          },
          autogenerate: { directory: 'formations' }
        },
      ],
      social: [
        { icon: 'github', label: 'GitHub', href: 'https://github.com/dianedef/winflowz' },
      ],
      lastUpdated: true,
      pagination: true,
    }),
    icon({
      include: {
        heroicons: ["*"],
        "phosphor-icons": ["*"]
      }
    }),
    tailwind({
      applyBaseStyles: false,
    }),
    sitemap({
      i18n: {
        defaultLocale: "en",
        locales: {
          en: "en",
          fr: "fr"
        }
      }
    }),
    react({
      include: ['**/components/react/**', '**/components/ui/**'],
    }),
    clerk(),
  ],
});
