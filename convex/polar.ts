import { internalMutation, mutation } from "./_generated/server";
import { v } from "convex/values";

async function findUserByEmail(ctx: { db: any }, email: string) {
  return await ctx.db
    .query("users")
    .withIndex("by_email", (q: any) => q.eq("email", email))
    .unique();
}

async function findUserByPolarCustomerId(ctx: { db: any }, polarCustomerId: string) {
  return await ctx.db
    .query("users")
    .withIndex("by_polarCustomerId", (q: any) =>
      q.eq("polarCustomerId", polarCustomerId)
    )
    .first();
}

function mergeEntitlements(existing: string[] | undefined, entitlement: string) {
  const current = new Set(existing ?? []);
  current.add(entitlement);
  return [...current];
}

export const updateSubscription = internalMutation({
  args: {
    polarCustomerId: v.string(),
    subscriptionStatus: v.string(),
    subscriptionTier: v.string(),
  },
  handler: async (ctx, args) => {
    const user = await findUserByPolarCustomerId(ctx, args.polarCustomerId);

    if (user) {
      await ctx.db.patch(user._id, {
        subscriptionStatus: args.subscriptionStatus,
        subscriptionTier: args.subscriptionTier,
      });
    }
  },
});

export const linkCustomer = internalMutation({
  args: {
    email: v.string(),
    polarCustomerId: v.string(),
  },
  handler: async (ctx, args) => {
    const user = await findUserByEmail(ctx, args.email);

    if (user) {
      await ctx.db.patch(user._id, {
        polarCustomerId: args.polarCustomerId,
      });
    }
  },
});

export const linkCustomerByEmail = mutation({
  args: {
    email: v.string(),
    polarCustomerId: v.string(),
  },
  handler: async (ctx, args) => {
    const user = await findUserByEmail(ctx, args.email);

    if (user) {
      await ctx.db.patch(user._id, {
        polarCustomerId: args.polarCustomerId,
      });
    }
  },
});

export const updateSubscriptionByCustomerId = mutation({
  args: {
    polarCustomerId: v.string(),
    subscriptionStatus: v.string(),
    subscriptionTier: v.string(),
  },
  handler: async (ctx, args) => {
    const user = await findUserByPolarCustomerId(ctx, args.polarCustomerId);

    if (user) {
      await ctx.db.patch(user._id, {
        subscriptionStatus: args.subscriptionStatus,
        subscriptionTier: args.subscriptionTier,
      });
    }
  },
});

export const grantCourseAccessByEmail = mutation({
  args: {
    email: v.string(),
    entitlement: v.string(),
    polarCustomerId: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const user = await findUserByEmail(ctx, args.email);

    if (!user) {
      return { granted: false };
    }

    await ctx.db.patch(user._id, {
      polarCustomerId: args.polarCustomerId ?? user.polarCustomerId,
      courseEntitlements: mergeEntitlements(user.courseEntitlements, args.entitlement),
    });

    return { granted: true };
  },
});

export const grantCourseAccess = internalMutation({
  args: {
    email: v.string(),
    entitlement: v.string(),
    polarCustomerId: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const user = await findUserByEmail(ctx, args.email);

    if (!user) {
      return { granted: false };
    }

    await ctx.db.patch(user._id, {
      polarCustomerId: args.polarCustomerId ?? user.polarCustomerId,
      courseEntitlements: mergeEntitlements(user.courseEntitlements, args.entitlement),
    });

    return { granted: true };
  },
});
