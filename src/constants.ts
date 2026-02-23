import ogImageSrc from "@/assets/images/WinFlowz.png";

export const SITE = {
  name: 'WinFlowz',
  title: 'WinFlowz - Productivity Plugins & Windows Training',
  description: 'Transform your digital workflow with Chrome extensions for YouTube, Obsidian plugins for content management, and a complete Windows productivity guide with 200+ tested tips.',
  author: 'Diane Defores',
  url: 'https://winflowz.com',
  githubUrl: 'https://github.com/dianedef/winflowz',
  ogImage: '/images/WinFlowz.png'
};

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
  description: "Chrome extensions for YouTube, Obsidian plugins for content management, and a Windows productivity guide with 200+ tested tips. Built by a neurodivergent solopreneur. 5/5 on AppSumo.",
  image: ogImageSrc,
};
