import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  users: defineTable({
    clerkId: v.string(),
    email: v.string(),
    name: v.optional(v.string()),
    imageUrl: v.optional(v.string()),
    role: v.optional(v.string()),
    polarCustomerId: v.optional(v.string()),
    subscriptionTier: v.optional(v.string()),
    subscriptionStatus: v.optional(v.string()),
    courseEntitlements: v.optional(v.array(v.string())),
  }).index("by_clerkId", ["clerkId"])
    .index("by_email", ["email"])
    .index("by_polarCustomerId", ["polarCustomerId"]),

  apiKeys: defineTable({
    userId: v.id("users"),
    name: v.string(),
    key: v.string(),
    isRevoked: v.boolean(),
  }).index("by_userId", ["userId"]),

  features: defineTable({
    title: v.string(),
    description: v.string(),
    status: v.string(),
    projectId: v.string(),
    votes: v.number(),
  }).index("by_projectId", ["projectId"])
    .index("by_status", ["status"]),
});
