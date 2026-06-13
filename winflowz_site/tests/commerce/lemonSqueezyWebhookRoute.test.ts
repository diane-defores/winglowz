import { describe, test, expect, beforeEach, vi } from 'vitest'

const mockMutation = vi.fn()

vi.mock('convex/browser', () => ({
  ConvexHttpClient: vi.fn().mockImplementation(function () {
    return {
      mutation: mockMutation,
    }
  }),
}))

function toHex(bytes: ArrayBuffer) {
  return [...new Uint8Array(bytes)]
    .map((value) => value.toString(16).padStart(2, '0'))
    .join('')
}

async function signWebhook(body: string, secret: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  )
  return toHex(await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(body)))
}

describe('lemon squeezy webhook route', () => {
  beforeEach(() => {
    mockMutation.mockReset()
    process.env.PUBLIC_CONVEX_URL = 'https://convex.example.com'
    process.env.LEMONSQUEEZY_WEBHOOK_SECRET = 'webhook-secret'
    process.env.SUITE_BRIDGE_CONVEX_SECRET = 'convex-secret'
  })

  test('forwards signed WinFlowz events to the generic suite commerce processor', async () => {
    const { POST } = await import('@/pages/api/commerce/webhooks/lemon-squeezy')
    mockMutation.mockResolvedValueOnce({
      ok: true,
      status: 'pending_review',
      alreadyProcessed: false,
    })

    const body = JSON.stringify({
      data: {
        id: 'ord_wfz',
        attributes: {
          customer_id: 'cus_wfz',
          user_email: 'buyer@example.com',
          first_order_item: { test_mode: true },
        },
      },
      event_id: 'evt_wfz',
      event_name: 'order_created',
      meta: {
        custom_data: {
          offer_id: 'winflowz_app/power',
          product_id: 'winflowz_app',
          plan: 'power',
          source: 'direct',
          source_ref: '/winflowz-founder',
        },
      },
    })
    const signature = await signWebhook(body, 'webhook-secret')

    const response = await POST({
      request: new Request('https://winflowz.test/api/commerce/webhooks/lemon-squeezy', {
        method: 'POST',
        headers: {
          'x-signature': signature,
          'x-event-name': 'order_created',
          'x-event-id': 'evt_wfz',
        },
        body,
      }),
    })

    expect(response.status).toBe(200)
    expect(mockMutation).toHaveBeenCalledWith(
      'bridge:processCommerceEvent',
      expect.objectContaining({
        provider: 'lemonsqueezy',
        offerId: 'winflowz_app/power',
        productId: 'winflowz_app',
        plan: 'power',
        eventType: 'paid',
        providerOrderId: 'ord_wfz',
        bridgeSecret: 'convex-secret',
      })
    )
  })
})
