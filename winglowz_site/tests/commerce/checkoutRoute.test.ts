import { describe, test, expect, afterEach, vi } from 'vitest'
import { GET } from '@/pages/api/commerce/checkout'

const ORIGINAL_FETCH = globalThis.fetch
const ORIGINAL_ENV = { ...process.env }

function resetCommerceEnv() {
  delete process.env.LEMONSQUEEZY_API_KEY
  delete process.env.LEMONSQUEEZY_STORE_ID
  delete process.env.LEMONSQUEEZY_SOCIALGLOWZ_LIFETIME_DEAL_VARIANT_ID
  delete process.env.LEMONSQUEEZY_WINGLOWZ_APP_POWER_VARIANT_ID
  delete process.env.LEMONSQUEEZY_API_URL
  delete process.env.POLAR_WINGLOWZ_PRODUCT_ID
  delete process.env.POLAR_PRODUCT_ID
  delete process.env.COMMERCE_PROVIDER_ORDER
}

function checkoutRequest(url: string) {
  return new Request(url)
}

afterEach(() => {
  globalThis.fetch = ORIGINAL_FETCH
  process.env = { ...ORIGINAL_ENV }
  resetCommerceEnv()
})

describe('commerce checkout route', () => {
  test('rejects missing offerId instead of falling back to SocialGlowz', async () => {
    resetCommerceEnv()

    const response = await GET({
      request: checkoutRequest('https://winglowz.test/api/commerce/checkout'),
    })

    expect(response.status).toBe(400)
    await expect(response.json()).resolves.toEqual({
      message: 'Missing offerId',
    })
  })

  test('returns unavailable when no checkout provider is configured', async () => {
    resetCommerceEnv()

    const response = await GET({
      request: checkoutRequest(
        'https://winglowz.test/api/commerce/checkout?offerId=socialglowz/lifetime_deal&successUrl=https://socialglowz.test/purchase/success&cancelUrl=https://socialglowz.test/purchase/cancel'
      ),
    })

    expect(response.status).toBe(503)
    await expect(response.json()).resolves.toEqual({
      message: 'No configured checkout provider',
    })
  })

  test('rejects unknown offers before contacting a provider', async () => {
    resetCommerceEnv()
    const fetchSpy = vi.fn()
    globalThis.fetch = fetchSpy as unknown as typeof fetch

    const response = await GET({
      request: checkoutRequest(
        'https://winglowz.test/api/commerce/checkout?offerId=unknown/offer'
      ),
    })

    expect(response.status).toBe(404)
    await expect(response.json()).resolves.toEqual({
      message: 'Offer not found',
    })
    expect(fetchSpy).not.toHaveBeenCalled()
  })

  test('redirects to the hosted Lemon Squeezy checkout URL', async () => {
    resetCommerceEnv()
    process.env.LEMONSQUEEZY_API_KEY = 'api-key'
    process.env.LEMONSQUEEZY_STORE_ID = 'store-id'
    process.env.LEMONSQUEEZY_SOCIALGLOWZ_LIFETIME_DEAL_VARIANT_ID = 'variant-id'

    const fetchSpy = vi.fn().mockResolvedValue(
      new Response(
        JSON.stringify({
          data: {
            id: 'co_route_123',
            attributes: { url: 'https://checkout.lemonsqueezy.test/route' },
          },
        }),
        { status: 200, headers: { 'content-type': 'application/json' } }
      )
    )
    globalThis.fetch = fetchSpy as unknown as typeof fetch

    const response = await GET({
      request: checkoutRequest(
        'https://winglowz.test/api/commerce/checkout?offerId=socialglowz/lifetime_deal&source=direct&successUrl=https://socialglowz.test/purchase/success&cancelUrl=https://socialglowz.test/purchase/cancel'
      ),
    })

    expect(response.status).toBe(302)
    expect(response.headers.get('location')).toBe(
      'https://checkout.lemonsqueezy.test/route'
    )

    const body = String(fetchSpy.mock.calls[0]?.[1]?.body)
    expect(body).toContain(
      '"product_options":{"redirect_url":"https://socialglowz.test/purchase/success"}'
    )
    expect(body).toContain('"offer_id":"socialglowz/lifetime_deal"')
    expect(body).not.toContain('api-key')
  })

  test('redirects WinGlows founder checkout to Lemon Squeezy', async () => {
    resetCommerceEnv()
    process.env.LEMONSQUEEZY_API_KEY = 'api-key'
    process.env.LEMONSQUEEZY_STORE_ID = 'store-id'
    process.env.LEMONSQUEEZY_WINGLOWZ_APP_POWER_VARIANT_ID = 'winglowz-power-variant'

    const fetchSpy = vi.fn().mockResolvedValue(
      new Response(
        JSON.stringify({
          data: {
            id: 'co_wfz_route',
            attributes: { url: 'https://checkout.lemonsqueezy.test/winglowz' },
          },
        }),
        { status: 200, headers: { 'content-type': 'application/json' } }
      )
    )
    globalThis.fetch = fetchSpy as unknown as typeof fetch

    const response = await GET({
      request: checkoutRequest(
        'https://winglowz.test/api/commerce/checkout?offerId=winglowz_app/power&provider=lemonsqueezy&source=direct&sourceRef=/winglowz-founder&successUrl=https://winglowz.test/purchase/success?offerId=winglowz_app%2Fpower&cancelUrl=https://winglowz.test/purchase/cancel?offerId=winglowz_app%2Fpower'
      ),
    })

    expect(response.status).toBe(302)
    expect(response.headers.get('location')).toBe(
      'https://checkout.lemonsqueezy.test/winglowz'
    )

    const body = String(fetchSpy.mock.calls[0]?.[1]?.body)
    expect(body).toContain('"offer_id":"winglowz_app/power"')
    expect(body).toContain('"product_id":"winglowz_app"')
    expect(body).toContain('"plan":"power"')
    expect(body).toContain('"id":"winglowz-power-variant"')
    expect(body).not.toContain('api-key')
  })
})
