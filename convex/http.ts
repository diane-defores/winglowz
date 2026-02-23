import { httpRouter } from "convex/server";
import { httpAction } from "./_generated/server";
import { internal } from "./_generated/api";

const http = httpRouter();

http.route({
  path: "/polar/events",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    const webhookSecret = process.env.POLAR_WEBHOOK_SECRET;
    if (!webhookSecret) {
      return new Response("Webhook secret not configured", { status: 500 });
    }

    const body = await request.text();

    try {
      const event = JSON.parse(body);

      if (event.type === "subscription.created" || event.type === "subscription.updated") {
        const subscription = event.data;
        const customerId = subscription.customer_id;
        const status = subscription.status;
        const tier = subscription.product?.name || "pro";

        await ctx.runMutation(internal.polar.updateSubscription, {
          polarCustomerId: customerId,
          subscriptionStatus: status,
          subscriptionTier: tier,
        });
      }

      if (event.type === "checkout.completed") {
        const checkout = event.data;
        const customerEmail = checkout.customer_email;
        const customerId = checkout.customer_id;

        if (customerEmail && customerId) {
          await ctx.runMutation(internal.polar.linkCustomer, {
            email: customerEmail,
            polarCustomerId: customerId,
          });
        }
      }

      return new Response("OK", { status: 200 });
    } catch {
      return new Response("Invalid payload", { status: 400 });
    }
  }),
});

export default http;
