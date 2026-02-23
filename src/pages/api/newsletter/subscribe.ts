import type { APIRoute } from 'astro';
import { Resend } from 'resend';

export const POST: APIRoute = async ({ request }) => {
  const resendKey = import.meta.env.RESEND_API_KEY;
  if (!resendKey || resendKey === 're_PLACEHOLDER') {
    return new Response(
      JSON.stringify({ error: 'Newsletter service not configured' }),
      { status: 503, headers: { 'Content-Type': 'application/json' } }
    );
  }

  const resend = new Resend(resendKey);

  try {
    const body = await request.json();
    const { email, source } = body;

    if (!email || typeof email !== 'string' || !email.includes('@')) {
      return new Response(
        JSON.stringify({ error: 'Valid email is required' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // Add contact to Resend audience
    await resend.contacts.create({
      email,
      audienceId: import.meta.env.RESEND_AUDIENCE_ID || '',
      unsubscribed: false,
    });

    // Send welcome email
    await resend.emails.send({
      from: 'WinFlowz <newsletter@winflowz.com>',
      to: email,
      subject: 'Welcome to WinFlowz Newsletter!',
      html: `
        <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto;">
          <h1 style="color: #ff00c8;">Welcome to WinFlowz!</h1>
          <p>Thanks for subscribing to our newsletter. You'll receive weekly tips on Windows productivity, extension updates, and exclusive content.</p>
          <p>In the meantime, check out our <a href="https://winflowz.com/products" style="color: #ff00c8;">tools and extensions</a>.</p>
          <p>— Diane Defores, WinFlowz</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;" />
          <p style="font-size: 12px; color: #999;">You can <a href="https://winflowz.com/api/newsletter/unsubscribe?email=${encodeURIComponent(email)}">unsubscribe</a> at any time.</p>
        </div>
      `,
    });

    return new Response(
      JSON.stringify({ success: true }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    );
  } catch (err) {
    console.error('Newsletter subscribe error:', err);
    return new Response(
      JSON.stringify({ error: 'Failed to subscribe' }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
};
