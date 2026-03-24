import { httpRouter } from "convex/server";
import { httpAction } from "./_generated/server";
import { internal } from "./_generated/api";

const http = httpRouter();

const COURSE_ENTITLEMENT = "winflowz-training";

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
      const productId = process.env.POLAR_WINFLOWZ_PRODUCT_ID;

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

      if (event.type === "order.paid") {
        const order = event.data;
        const customerEmail = order.customer?.email;
        const customerId = order.customer_id;
        const matchesFormation =
          order.metadata?.entitlement === COURSE_ENTITLEMENT ||
          (productId ? order.product_id === productId : false);

        if (customerEmail && matchesFormation) {
          await ctx.runMutation(internal.polar.grantCourseAccess, {
            email: customerEmail,
            entitlement: COURSE_ENTITLEMENT,
            polarCustomerId: customerId || undefined,
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
