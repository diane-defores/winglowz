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

    // Verify webhook signature using svix
    const webhookId = request.headers.get("webhook-id") ?? "";
    const webhookTimestamp = request.headers.get("webhook-timestamp") ?? "";
    const webhookSignature = request.headers.get("webhook-signature") ?? "";

    if (!webhookId || !webhookTimestamp || !webhookSignature) {
      return new Response("Missing webhook verification headers", { status: 403 });
    }

    // Verify timestamp is within tolerance (5 minutes)
    const timestampSeconds = parseInt(webhookTimestamp, 10);
    const now = Math.floor(Date.now() / 1000);
    if (isNaN(timestampSeconds) || Math.abs(now - timestampSeconds) > 300) {
      return new Response("Webhook timestamp too old", { status: 403 });
    }

    // Verify HMAC signature
    const signedContent = `${webhookId}.${webhookTimestamp}.${body}`;
    const secretBytes = base64ToUint8Array(webhookSecret.replace(/^whsec_/, ""));

    const key = await crypto.subtle.importKey(
      "raw",
      secretBytes,
      { name: "HMAC", hash: "SHA-256" },
      false,
      ["sign"]
    );
    const signatureBytes = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(signedContent));
    const expectedSignature = uint8ArrayToBase64(new Uint8Array(signatureBytes));

    const signatures = webhookSignature.split(" ");
    const isValid = signatures.some((sig) => {
      const sigValue = sig.replace(/^v1,/, "");
      return sigValue === expectedSignature;
    });

    if (!isValid) {
      return new Response("Invalid webhook signature", { status: 403 });
    }

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
    } catch (error) {
      console.error("Polar webhook handling failed:", error);
      return new Response("Invalid payload", { status: 400 });
    }
  }),
});

http.route({
  path: "/clerk/events",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    const webhookSecret = process.env.CLERK_WEBHOOK_SECRET;
    if (!webhookSecret) {
      return new Response("Clerk webhook secret not configured", { status: 500 });
    }

    const body = await request.text();

    // Verify svix signature
    const svixId = request.headers.get("svix-id") ?? "";
    const svixTimestamp = request.headers.get("svix-timestamp") ?? "";
    const svixSignature = request.headers.get("svix-signature") ?? "";

    if (!svixId || !svixTimestamp || !svixSignature) {
      return new Response("Missing svix verification headers", { status: 403 });
    }

    const timestampSeconds = parseInt(svixTimestamp, 10);
    const now = Math.floor(Date.now() / 1000);
    if (isNaN(timestampSeconds) || Math.abs(now - timestampSeconds) > 300) {
      return new Response("Webhook timestamp too old", { status: 403 });
    }

    const signedContent = `${svixId}.${svixTimestamp}.${body}`;
    const secretBytes = base64ToUint8Array(webhookSecret.replace(/^whsec_/, ""));

    const key = await crypto.subtle.importKey(
      "raw",
      secretBytes,
      { name: "HMAC", hash: "SHA-256" },
      false,
      ["sign"]
    );
    const signatureBytes = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(signedContent));
    const expectedSignature = uint8ArrayToBase64(new Uint8Array(signatureBytes));

    const signatures = svixSignature.split(" ");
    const isValid = signatures.some((sig) => {
      const sigValue = sig.replace(/^v1,/, "");
      return sigValue === expectedSignature;
    });

    if (!isValid) {
      return new Response("Invalid webhook signature", { status: 403 });
    }

    try {
      const event = JSON.parse(body);

      switch (event.type) {
        case "user.created":
        case "user.updated": {
          await ctx.runMutation(internal.users.upsertFromClerk, {
            clerkId: event.data.id,
            email: event.data.email_addresses?.[0]?.email_address ?? "",
            name: [event.data.first_name, event.data.last_name].filter(Boolean).join(" ") || undefined,
            imageUrl: event.data.image_url || undefined,
          });
          break;
        }
        case "user.deleted": {
          if (event.data.id) {
            await ctx.runMutation(internal.users.deleteByClerkId, {
              clerkId: event.data.id,
            });
          }
          break;
        }
      }

      return new Response(JSON.stringify({ success: true }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    } catch (error) {
      console.error("Clerk webhook handling failed:", error);
      return new Response("Webhook handling failed", { status: 400 });
    }
  }),
});

function base64ToUint8Array(base64: string): Uint8Array {
  const binaryString = atob(base64);
  const bytes = new Uint8Array(binaryString.length);
  for (let i = 0; i < binaryString.length; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes;
}

function uint8ArrayToBase64(bytes: Uint8Array): string {
  let binary = "";
  for (let i = 0; i < bytes.length; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return btoa(binary);
}

export default http;
