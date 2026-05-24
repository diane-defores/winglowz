import { v } from "convex/values";
import { mutation, query } from "./_generated/server";

export const list = query({
  args: { projectId: v.optional(v.string()) },
  handler: async (ctx, args) => {
    if (args.projectId) {
      return await ctx.db
        .query("features")
        .withIndex("by_projectId", (q) => q.eq("projectId", args.projectId!))
        .collect();
    }
    return await ctx.db.query("features").collect();
  },
});

export const vote = mutation({
  args: { id: v.id("features") },
  handler: async (ctx, args) => {
    const feature = await ctx.db.get(args.id);
    if (feature) {
      await ctx.db.patch(args.id, { votes: feature.votes + 1 });
    }
  },
});
