// https://docs.astro.build/en/guides/content-collections/#defining-collections

import { z, defineCollection } from 'astro:content';
import { docsSchema } from '@astrojs/starlight/schema';

// Extension du schéma Starlight pour les cours
const courseSchema = docsSchema({
  extend: z.object({
    courseData: z.object({
      translations: z.object({
        en: z.object({
          title: z.string(),
          description: z.string(),
          objectives: z.array(z.string()).optional(),
          prerequisites: z.array(z.string()).optional(),
        }),
        fr: z.object({
          title: z.string(),
          description: z.string(),
          objectives: z.array(z.string()).optional(),
          prerequisites: z.array(z.string()).optional(),
        }),
      }),
      duration: z.string().optional(),
      level: z.enum(['beginner', 'intermediate', 'advanced']).optional(),
      featured: z.boolean().optional(),
      order: z.number().optional(),
      components: z.array(
        z.object({
          type: z.enum(['video', 'quiz', 'exercise', 'resources']),
          data: z.record(z.any()),
        })
      ).optional(),
    }).optional(),
  }),
});

const productsCollection = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    main: z.object({
      id: z.number(),
      content: z.string(),
      imgCard: z.string(),
      imgMain: z.string(),
      imgAlt: z.string(),
    }),
    tabs: z.array(
      z.object({
        id: z.string(),
        dataTab: z.string(),
        title: z.string(),
      })
    ),
    longDescription: z.object({
      title: z.string(),
      subTitle: z.string(),
      btnTitle: z.string(),
      btnURL: z.string(),
    }),
    descriptionList: z.array(
      z.object({
        title: z.string(),
        subTitle: z.string(),
      })
    ),
    specificationsLeft: z.array(
      z.object({
        title: z.string(),
        subTitle: z.string(),
      })
    ),
    specificationsRight: z.array(
      z.object({
        title: z.string(),
        subTitle: z.string(),
      })
    ).optional(),
    tableData: z.array(
      z.object({
        feature: z.array(z.string()),
        description: z.array(z.array(z.string())),
      })
    ).optional(),
    blueprints: z.object({
      first: z.string().optional(),
      second: z.string().optional(),
    }),
  }),
});

const blogCollection = defineCollection({
  type: "content",
  schema: z.object({
    title: z.string(),
    description: z.string(),
    contents: z.array(z.string()),
    author: z.string(),
    role: z.string().optional(),
    authorImage: z.string(),
    authorImageAlt: z.string(),
    pubDate: z.date(),
    draft: z.boolean().optional().default(false),
    cardImage: z.string(),
    cardImageAlt: z.string(),
    readTime: z.number(),
    tags: z.array(z.string()).optional(),
  }),
});

const servicesCollection = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    icon: z.string().optional(),
    features: z.array(z.string()).optional(),
    image: z.string().optional(),
    imageAlt: z.string().optional(),
  }),
});

export const collections = {
  docs: defineCollection({ schema: courseSchema }),
  'products': productsCollection,
  'blog': blogCollection,
  'services': servicesCollection,
};