# Recorded run: 4 Nov 2026 (n8n Cloud, production webhooks)

Demo delays: reminder 1 after 2 min, reminder 2 after 3 more min. Test contact = the developer's own email and WhatsApp number (shown here as `<test email>` / `<test phone>`).

| n8n execution | Scenario | Input | Result |
|---|---|---|---|
| #65 | Full recovery sequence | `checkouts/create`, token `tok_demo_full_002`, consent = true | ✅ Row logged `pending` → after 2 min status still `pending` → AI wrote reminder 1 → email sent → `reminder_1_sent` set → after 3 min still `pending` → AI wrote reminder 2 with `COMEBACK10` → email sent → status `reminders_complete`. WhatsApp attempted twice, failed after 3 retries each (Twilio trial, error 21654), flow continued as designed. |
| #66 | Two checkouts at the same second | `tok_demo_concurrent_002`, sent alongside #65 | ✅ Own row (no overwrite), same sequence as #65 |
| #62 + #64 | Customer buys before reminder 1 | `tok_demo_recovered_001`, then `orders/create` with matching `checkout_token` | ✅ #64 set status `recovered`; #62 woke after 2 min, saw `recovered`, stopped at **Still Abandoned? (1)**; no messages sent |
| #63 | No marketing consent | `tok_demo_noconsent_001`, `buyer_accepts_marketing = false` | ✅ Stopped at **Has Contact + Consent?**; nothing logged or sent |

## Bug found and fixed during testing

Execution #61 (run at the same second as #62) logged its row, but #62's row was written to the same empty sheet row and overwrote it, so #61's later status lookup found nothing and it stopped. Fix: **Log Cart (pending)** now uses Google Sheets' atomic append (`useAppend: true`). Re-tested in #65 + #66 (sent together): both rows kept.

## Sample AI output (reminder 2, from #65)

> Hey Eriola! We noticed you left some goodies in your cart. Don't miss out on your chance to save 10% with code COMEBACK10! Complete your purchase before they're gone: [Checkout here](https://slumdog-kl88zbxf.myshopify.com/checkouts/demo-full-2). Happy shopping!

`ai_fallback_used = false` for every AI step in #65 and #66.
