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
        ...(process.env.NODE_ENV === 'production'
          ? [
              {
                tag: /** @type {const} */ ('script'),
                content: `
                  !function(t,e){var o,n,p,r;e.__SV||(window.posthog=e,e._i=[],e.init=function(i,s,a){function g(t,e){var o=e.split(".");2==o.length&&(t=t[o[0]],e=o[1]),t[e]=function(){t.push([e].concat(Array.prototype.slice.call(arguments,0)))}}(p=t.createElement("script")).type="text/javascript",p.crossOrigin="anonymous",p.async=!0,p.src=s.api_host.replace(".i.posthog.com","-assets.i.posthog.com")+"/static/array.js",(r=t.getElementsByTagName("script")[0]).parentNode.insertBefore(p,r);var u=e;for(void 0!==a?u=e[a]=[]:a="posthog",u.people=u.people||[],u.toString=function(t){var e="posthog";return"posthog"!==a&&(e+="."+a),t||(e+=" (stub)"),e},u.people.toString=function(){return u.toString(1)+".people (stub)"},o="init capture register register_once register_for_session unregister unregister_for_session getFeatureFlag getFeatureFlagPayload isFeatureEnabled reloadFeatureFlags updateEarlyAccessFeatureEnrollment getEarlyAccessFeatures on onFeatureFlags onSessionId getSurveys getActiveMatchingSurveys renderSurvey canRenderSurvey getNextSurveyStep identify setPersonProperties group resetGroups setPersonPropertiesForFlags resetPersonPropertiesForFlags setGroupPropertiesForFlags resetGroupPropertiesForFlags reset get_distinct_id getGroups get_session_id get_session_replay_url alias set_config startSessionRecording stopSessionRecording sessionRecordingStarted captureException loadToolbar get_property getSessionProperty createPersonProfile opt_in_capturing opt_out_capturing has_opted_in_capturing has_opted_out_capturing clear_opt_in_out_capturing debug".split(" "),n=0;n<o.length;n++)g(u,o[n]);e._i.push([i,s,a])},e.__SV=1)}(document,window.posthog||[]);
                  posthog.init('phc_qpA8Gxd3jSp8qleWtm3bE5WKsK3aMdmkhjDVeQ8p40u', {
                    api_host: 'https://us.i.posthog.com',
                    person_profiles: 'identified_only',
                  });
                `,
              },
            ]
          : []),
      ],
      customCss: [
        './src/assets/styles/global.css',
        './src/assets/styles/starlight.css'
      ],
      components: {
        SkipLink: '@components/overrides/EmptySkipLink.astro',
        Page: '@components/overrides/StarlightPage.astro'
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
          autogenerate: {
            directory: 'Welcome'
          }
        },
        {
          label: 'Formations',
          items: [
            { label: 'Vue d\'ensemble', link: '/fr/formations/' },
            {
              label: 'I — La Productivité',
              collapsed: true,
              autogenerate: { directory: 'fr/formations/module-1-productivite' }
            },
            {
              label: 'II — Windows',
              collapsed: true,
              autogenerate: { directory: 'fr/formations/module-2-windows' }
            },
            {
              label: 'III — Temps & Énergie',
              collapsed: true,
              autogenerate: { directory: 'fr/formations/module-3-temps-energie' }
            },
            {
              label: 'IV — Gestion des Actions',
              collapsed: true,
              autogenerate: { directory: 'fr/formations/module-4-actions' }
            },
            {
              label: 'V — Consommer',
              collapsed: true,
              autogenerate: { directory: 'fr/formations/module-5-consommer' }
            },
            {
              label: 'VI — Connaissances',
              collapsed: true,
              autogenerate: { directory: 'fr/formations/module-6-connaissance' }
            },
            {
              label: 'VII — Social',
              collapsed: true,
              autogenerate: { directory: 'fr/formations/module-7-social' }
            },
            {
              label: 'VIII — Raccourcis',
              collapsed: true,
              autogenerate: { directory: 'fr/formations/module-8-raccourcis' }
            },
          ]
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
