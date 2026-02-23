import { internalMutation } from "./_generated/server";
import { v } from "convex/values";

export const updateSubscription = internalMutation({
  args: {
    polarCustomerId: v.string(),
    subscriptionStatus: v.string(),
    subscriptionTier: v.string(),
  },
  handler: async (ctx, args) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_polarCustomerId", (q) =>
        q.eq("polarCustomerId", args.polarCustomerId)
      )
      .first();

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
    const users = await ctx.db.query("users").collect();
    const user = users.find((u) => u.email === args.email);

    if (user) {
      await ctx.db.patch(user._id, {
        polarCustomerId: args.polarCustomerId,
      });
    }
  },
});
