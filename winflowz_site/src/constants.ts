import ogImageSrc from "@/assets/images/WinFlowz.png";

export const SITE = {
  name: 'WinFlowz',
  title: 'WinFlowz - Productivity Plugins & Windows Training',
  description: 'Windows training in 8 modules, Obsidian plugins, and Chrome tools for building a practical workflow.',
  author: 'Diane Defores',
  authorName: 'Diane Defores',
  url: 'https://winflowz.com',
  domain: 'winflowz.com',
  githubUrl: 'https://github.com/diane-defores/winflowz',
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
  description: "Windows training in 8 modules, Obsidian plugins, and Chrome tools for building a practical workflow.",
  image: ogImageSrc,
};

export const SITE_VISUAL_TOKENS = {
  themeMeta: {
    website: '#facc15',
    manifestTheme: '#000000',
    manifestBackground: '#ffffff',
    manifestDescription: OG.description,
    twitterCard: 'summary_large_image',
  },
  socialImage: {
    width: 1200,
    height: 600,
    type: 'image/png',
  },
  manifestIcons: {
    sizes: [192, 512],
  },
  bio: {
    avatarSize: 96,
    socialIconSize: 26,
    footerYear: 2026,
  },
}
