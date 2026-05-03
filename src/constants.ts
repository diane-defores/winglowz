import ogImageSrc from "@/assets/images/WinFlowz.png";

export const SITE = {
  name: 'WinFlowz',
  title: 'WinFlowz - Productivity Plugins & Windows Training',
  description: 'Windows training in 8 modules, Obsidian plugins, and Chrome tools for building a smoother workflow with 200+ tested tips.',
  author: 'Diane Defores',
  authorName: 'Diane Defores',
  url: 'https://winflowz.com',
  domain: 'winflowz.com',
  githubUrl: 'https://github.com/dianedef/winflowz',
  ogImage: '/images/WinFlowz.png',
  emails: {
    contact: 'hello@winflowz.com',
    support: 'support@winflowz.com',
    legal: 'legal@winflowz.com',
    privacy: 'privacy@winflowz.com',
    copyright: 'copyright@winflowz.com',
    newsletter: 'newsletter@winflowz.com',
  },
};

export function getSiteUrl(path = '/') {
  return new URL(path, SITE.url).toString();
}

export function getLocalizedSiteUrl(lang: 'en' | 'fr', path = '/') {
  const normalizedPath = path.startsWith('/') ? path : `/${path}`;
  if (lang === 'fr') {
    return getSiteUrl(`/fr${normalizedPath === '/' ? '' : normalizedPath}`);
  }

  return getSiteUrl(normalizedPath);
}

export const SEO = {
  title: SITE.title,
  description: SITE.description,
  structuredData: {
    "@context": "https://schema.org",
    "@type": "WebPage",
    inLanguage: "en-US",
    "@id": SITE.url,
    url: SITE.url,
    name: SITE.title,
    description: SITE.description,
    isPartOf: {
      "@type": "WebSite",
      url: SITE.url,
      name: SITE.title,
      description: SITE.description,
    },
  },
};

export const OG = {
  locale: "en_US",
  type: "website",
  url: SITE.url,
  title: `WinFlowz - Productivity Plugins & Windows Training`,
  description: "Windows training in 8 modules, Obsidian plugins, and Chrome tools for building a smoother workflow with 200+ tested tips. Built by a neurodivergent solopreneur with dozens of 5-star AppSumo reviews.",
  image: ogImageSrc,
};
