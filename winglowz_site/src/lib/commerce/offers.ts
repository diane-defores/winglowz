import type {
  CommerceOffer,
  CommerceOfferId,
  CommerceProviderId,
  CommerceProviderConfig,
  CommerceCheckoutRequest,
  CommerceCheckoutCustomData,
} from "./types"

import { getServerEnv } from "../serverEnv"

const SOCIALGLOWZ_OFFER_ID = "socialglowz/lifetime_deal"
const SOCIALGLOWZ_PRODUCT_ID = "socialglowz"
const SOCIALGLOWZ_PLAN = "lifetime_deal"
const WINGLOWZ_APP_PRODUCT_ID = "winglowz_app"
const WINGLOWZ_APP_FOCUS_OFFER_ID = "winglowz_app/focus"
const WINGLOWZ_APP_POWER_OFFER_ID = "winglowz_app/power"
const WINGLOWZ_APP_CONTROL_OFFER_ID = "winglowz_app/control"
const WINGLOWZ_APP_COMMAND_OFFER_ID = "winglowz_app/command"
const SOCIALGLOWZ_SOURCES = [
  "direct",
  "partner",
  "appsumo",
  "manual",
  "legacy",
] as const
const WINGLOWZ_APP_SOURCES = [
  "direct",
  "partner",
  "appsumo",
  "manual",
  "legacy",
] as const

const OFFER_BY_ID: Record<CommerceOfferId, CommerceOffer> = {
  [SOCIALGLOWZ_OFFER_ID]: {
    id: SOCIALGLOWZ_OFFER_ID,
    productId: SOCIALGLOWZ_PRODUCT_ID,
    plan: SOCIALGLOWZ_PLAN,
    sources: SOCIALGLOWZ_SOURCES,
    providers: ["lemonsqueezy", "polar"],
    successPath: "/purchase/success",
    cancelPath: "/purchase/cancel",
    description: "SocialGlowz Lifetime Deal, direct checkout",
  },
  [WINGLOWZ_APP_FOCUS_OFFER_ID]: {
    id: WINGLOWZ_APP_FOCUS_OFFER_ID,
    productId: WINGLOWZ_APP_PRODUCT_ID,
    plan: "focus",
    sources: WINGLOWZ_APP_SOURCES,
    providers: ["lemonsqueezy"],
    successPath: "/purchase/success?offerId=winglowz_app/focus",
    cancelPath: "/purchase/cancel?offerId=winglowz_app/focus",
    description: "WinGlows Focus founder access, 1 active device",
  },
  [WINGLOWZ_APP_POWER_OFFER_ID]: {
    id: WINGLOWZ_APP_POWER_OFFER_ID,
    productId: WINGLOWZ_APP_PRODUCT_ID,
    plan: "power",
    sources: WINGLOWZ_APP_SOURCES,
    providers: ["lemonsqueezy"],
    successPath: "/purchase/success?offerId=winglowz_app/power",
    cancelPath: "/purchase/cancel?offerId=winglowz_app/power",
    description: "WinGlows Power founder access, 2 active devices",
  },
  [WINGLOWZ_APP_CONTROL_OFFER_ID]: {
    id: WINGLOWZ_APP_CONTROL_OFFER_ID,
    productId: WINGLOWZ_APP_PRODUCT_ID,
    plan: "control",
    sources: WINGLOWZ_APP_SOURCES,
    providers: ["lemonsqueezy"],
    successPath: "/purchase/success?offerId=winglowz_app/control",
    cancelPath: "/purchase/cancel?offerId=winglowz_app/control",
    description: "WinGlows Control founder access, 5 active devices",
  },
  [WINGLOWZ_APP_COMMAND_OFFER_ID]: {
    id: WINGLOWZ_APP_COMMAND_OFFER_ID,
    productId: WINGLOWZ_APP_PRODUCT_ID,
    plan: "command",
    sources: WINGLOWZ_APP_SOURCES,
    providers: ["lemonsqueezy"],
    successPath: "/purchase/success?offerId=winglowz_app/command",
    cancelPath: "/purchase/cancel?offerId=winglowz_app/command",
    description: "WinGlows Command founder access, 10 active devices",
  },
} as const

export const SOCIALGLOWZ_LETTER = SOCIALGLOWZ_OFFER_ID
export const SOCIALGLOWZ_LTD_OFFER_ID = SOCIALGLOWZ_OFFER_ID
export const WINGLOWZ_APP_FOCUS_LTD_OFFER_ID = WINGLOWZ_APP_FOCUS_OFFER_ID
export const WINGLOWZ_APP_POWER_LTD_OFFER_ID = WINGLOWZ_APP_POWER_OFFER_ID
export const WINGLOWZ_APP_CONTROL_LTD_OFFER_ID = WINGLOWZ_APP_CONTROL_OFFER_ID
export const WINGLOWZ_APP_COMMAND_LTD_OFFER_ID = WINGLOWZ_APP_COMMAND_OFFER_ID

export function getCommerceOffers(): Record<string, CommerceOffer> {
  return { ...OFFER_BY_ID }
}

export function getCommerceOffer(offerId: string): CommerceOffer | null {
  return OFFER_BY_ID[offerId as CommerceOfferId] ?? null
}

export function isAllowedSocialGlowzOffer(
  offerId: string,
  productId: string,
  plan: string
): boolean {
  return (
    offerId === SOCIALGLOWZ_OFFER_ID &&
    productId === SOCIALGLOWZ_PRODUCT_ID &&
    plan === SOCIALGLOWZ_PLAN
  )
}

function getLemonSqueezyVariantEnvKey(offerId: string): string | null {
  if (offerId === SOCIALGLOWZ_OFFER_ID) {
    return "LEMONSQUEEZY_SOCIALGLOWZ_LIFETIME_DEAL_VARIANT_ID"
  }
  if (offerId === WINGLOWZ_APP_FOCUS_OFFER_ID) {
    return "LEMONSQUEEZY_WINGLOWZ_APP_FOCUS_VARIANT_ID"
  }
  if (offerId === WINGLOWZ_APP_POWER_OFFER_ID) {
    return "LEMONSQUEEZY_WINGLOWZ_APP_POWER_VARIANT_ID"
  }
  if (offerId === WINGLOWZ_APP_CONTROL_OFFER_ID) {
    return "LEMONSQUEEZY_WINGLOWZ_APP_CONTROL_VARIANT_ID"
  }
  if (offerId === WINGLOWZ_APP_COMMAND_OFFER_ID) {
    return "LEMONSQUEEZY_WINGLOWZ_APP_COMMAND_VARIANT_ID"
  }
  return null
}

function getLemonSqueezyProductEnvKey(offerId: string): string | null {
  if (offerId === SOCIALGLOWZ_OFFER_ID) {
    return "LEMONSQUEEZY_SOCIALGLOWZ_PRODUCT_ID"
  }
  if (
    offerId === WINGLOWZ_APP_FOCUS_OFFER_ID ||
    offerId === WINGLOWZ_APP_POWER_OFFER_ID ||
    offerId === WINGLOWZ_APP_CONTROL_OFFER_ID ||
    offerId === WINGLOWZ_APP_COMMAND_OFFER_ID
  ) {
    return "LEMONSQUEEZY_WINGLOWZ_APP_PRODUCT_ID"
  }
  return null
}

export function getOfferProviderConfig(
  offerId: string,
  provider: CommerceProviderId
): CommerceProviderConfig | null {
  const offer = getCommerceOffer(offerId)
  if (!offer || !offer.providers.includes(provider)) {
    return null
  }

  const env = getServerEnv()

  if (provider === "lemonsqueezy") {
    const variantEnvKey = getLemonSqueezyVariantEnvKey(offerId)
    const variantId = variantEnvKey ? env[variantEnvKey] : undefined
    if (!variantId) return null

    const storeId = env.LEMONSQUEEZY_STORE_ID
    const productEnvKey = getLemonSqueezyProductEnvKey(offerId)
    const productId = productEnvKey ? env[productEnvKey] : undefined
    return {
      provider,
      productId,
      variantId,
      storeId,
    }
  }

  if (provider === "polar") {
    const productId =
      env.POLAR_WINGLOWZ_PRODUCT_ID ?? env.POLAR_PRODUCT_ID ?? null

    return productId ? { provider, productId } : null
  }

  return null
}

export function getOfferProviderCandidates(
  offerId: string
): CommerceProviderId[] {
  const offer = getCommerceOffer(offerId)
  if (!offer) {
    return []
  }
  return [...offer.providers]
}

export function hasOfferProvider(offerId: string, provider: CommerceProviderId) {
  const offer = getCommerceOffer(offerId)
  return offer?.providers.includes(provider) ?? false
}

export function isKnownCommerceOfferId(
  offerId: string
): offerId is CommerceOfferId {
  return offerId in OFFER_BY_ID
}

export function buildCommerceCheckoutHints(
  offer: CommerceOffer,
  request: CommerceCheckoutRequest
): CommerceCheckoutCustomData {
  return {
    offer_id: offer.id,
    plan: offer.plan,
    product_id: offer.productId,
    source: request.metadata?.source || "direct",
    source_ref:
      request.metadata?.source_ref ?? request.idempotencyHint ?? undefined,
    global_user_id: request.metadata?.global_user_id,
  }
}

export function normalizeCommerceProviderOrder(
  offerId: string
): CommerceProviderId[] {
  const env = getServerEnv()
  const fallback: CommerceProviderId[] = ["lemonsqueezy", "polar"]
  const raw = env.COMMERCE_PROVIDER_ORDER?.split(",") ?? []
  const candidates = raw
    .map((candidate) => candidate.trim().toLowerCase())
    .filter((candidate) => candidate.length > 0)

  const candidateSet = new Set(
    candidates.length > 0 ? candidates : fallback
  )
  const ordered = [...candidateSet]
    .map((candidate) => {
      if (candidate === "lemonsqueezy") return "lemonsqueezy" as const
      if (candidate === "polar") return "polar" as const
      return null
    })
    .filter((candidate) => candidate !== null) as CommerceProviderId[]

  if (ordered.length === 0) {
    return fallback
  }

  const allowed = getOfferProviderCandidates(offerId)
  return ordered.filter((candidate) => allowed.includes(candidate))
}

export function getSocialGlowzCommerceOfferId(): CommerceOfferId {
  return SOCIALGLOWZ_OFFER_ID
}

export function getSocialGlowzDefaultPlan(): string {
  return SOCIALGLOWZ_PLAN
}
