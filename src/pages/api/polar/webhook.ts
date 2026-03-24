import type { APIRoute } from 'astro'
import { ConvexHttpClient } from 'convex/browser'
import {
	WebhookVerificationError,
	validateEvent,
} from '@polar-sh/sdk/webhooks'
import { COURSE_ENTITLEMENT } from '@/utils/courseGating'

type PolarWebhookPayload = {
	type: string
	data: {
		customerId?: string | null
		customerEmail?: string | null
		productId?: string | null
		metadata?: Record<string, unknown>
		customer?: {
			email?: string | null
		}
		status?: string
		product?: {
			name?: string | null
		}
	}
}

export const prerender = false

export const POST: APIRoute = async ({ request }) => {
	const webhookSecret = import.meta.env.POLAR_WEBHOOK_SECRET
	const convexUrl = import.meta.env.PUBLIC_CONVEX_URL
	const formationProductId =
		import.meta.env.POLAR_WINFLOWZ_PRODUCT_ID || import.meta.env.POLAR_PRODUCT_ID

	if (!webhookSecret) {
		return new Response('Webhook secret not configured', { status: 500 })
	}

	if (!convexUrl || convexUrl === 'https://PLACEHOLDER.convex.cloud') {
		return new Response('Convex is not configured', { status: 500 })
	}

	const requestBody = await request.text()

	let event: PolarWebhookPayload
	try {
		event = validateEvent(
			requestBody,
			{
				'webhook-id': request.headers.get('webhook-id') ?? '',
				'webhook-timestamp': request.headers.get('webhook-timestamp') ?? '',
				'webhook-signature': request.headers.get('webhook-signature') ?? '',
			},
			webhookSecret,
		) as PolarWebhookPayload
	} catch (error) {
		if (error instanceof WebhookVerificationError) {
			return new Response('Invalid signature', { status: 403 })
		}
		console.error('Polar webhook validation failed', error)
		return new Response('Invalid webhook payload', { status: 400 })
	}

	const convex = new ConvexHttpClient(convexUrl)

	try {
		if (event.type === 'checkout.completed') {
			const customerEmail = event.data.customerEmail
			const customerId = event.data.customerId

			if (customerEmail && customerId) {
				await convex.mutation('polar:linkCustomerByEmail' as never, {
					email: customerEmail,
					polarCustomerId: customerId,
				} as never)
			}
		}

		if (event.type === 'subscription.created' || event.type === 'subscription.updated') {
			const customerId = event.data.customerId
			const status = event.data.status
			const tier = event.data.product?.name

			if (customerId && status && tier) {
				await convex.mutation('polar:updateSubscriptionByCustomerId' as never, {
					polarCustomerId: customerId,
					subscriptionStatus: status,
					subscriptionTier: tier,
				} as never)
			}
		}

		if (event.type === 'order.paid') {
			const customerEmail = event.data.customer?.email
			const metadataEntitlement = event.data.metadata?.entitlement
			const matchesFormation =
				metadataEntitlement === COURSE_ENTITLEMENT ||
				(formationProductId ? event.data.productId === formationProductId : false)

			if (customerEmail && matchesFormation) {
				await convex.mutation('polar:grantCourseAccessByEmail' as never, {
					email: customerEmail,
					entitlement: COURSE_ENTITLEMENT,
					polarCustomerId: event.data.customerId ?? undefined,
				} as never)
			}
		}

		return Response.json({ received: true })
	} catch (error) {
		console.error('Polar webhook handling failed', error)
		return new Response('Webhook handling failed', { status: 500 })
	}
}
