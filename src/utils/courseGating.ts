import type { APIContext } from 'astro'
import { ConvexHttpClient } from 'convex/browser'

const COURSE_PRODUCT_BY_LANG = {
	en: '/products/winflowz',
	fr: '/fr/produits/winflowz',
} as const

export function isFormationSlug(slug: string) {
	return (
		slug === 'formations' ||
		slug === 'fr/formations' ||
		slug === 'en/formations' ||
		slug.includes('/formations/')
	)
}

export function getPrivateCoursePath(slug: string) {
	return `/dashboard/docs/${slug.replace(/^\/+/, '')}`
}

export function getCourseUnlockPath(slug: string, lang: 'en' | 'fr') {
	const next = encodeURIComponent(getPrivateCoursePath(slug))
	return `${COURSE_PRODUCT_BY_LANG[lang]}?next=${next}`
}

export function extractCoursePreview(body: string, maxParagraphs = 4) {
	const normalized = body
		.replace(/```[\s\S]*?```/g, '')
		.replace(/!\[[^\]]*\]\([^)]+\)/g, '')
		.replace(/\[([^\]]+)\]\([^)]+\)/g, '$1')
		.replace(/^#{1,6}\s+/gm, '')
		.replace(/^\s*[-*+]\s+/gm, '')
		.replace(/^\s*\d+\.\s+/gm, '')
		.replace(/`([^`]+)`/g, '$1')

	return normalized
		.split(/\n{2,}/)
		.map((paragraph) => paragraph.replace(/\n+/g, ' ').trim())
		.filter((paragraph) => paragraph.length > 80)
		.slice(0, maxParagraphs)
}

export async function getCourseAccess(context: APIContext) {
	const auth = context.locals.auth()
	if (!auth.userId) {
		return { isAuthenticated: false, hasAccess: false }
	}

	const convexUrl = import.meta.env.PUBLIC_CONVEX_URL
	if (!convexUrl || convexUrl === 'https://PLACEHOLDER.convex.cloud') {
		return { isAuthenticated: true, hasAccess: false }
	}

	try {
		const convex = new ConvexHttpClient(convexUrl)
		const user = await convex.query('users:getByClerkId' as never, {
			clerkId: auth.userId,
		} as never)

		const subscriptionStatus = user?.subscriptionStatus
		const hasActiveSubscription =
			subscriptionStatus === 'active' || subscriptionStatus === 'trialing'
		const hasAccess =
			user?.role === 'admin' ||
			(Boolean(user?.subscriptionTier) && hasActiveSubscription)

		return {
			isAuthenticated: true,
			hasAccess,
			user,
		}
	} catch {
		return { isAuthenticated: true, hasAccess: false }
	}
}
