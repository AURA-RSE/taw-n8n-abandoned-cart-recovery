# Test Checklist: Abandoned Cart Recovery

Run with demo delays (reminder 1 after 2 min, reminder 2 after 3 more min). Use only your own test email and phone.

| # | Scenario | How to run | Expected result | Pass |
|---|---|---|---|---|
| 1 | Checkout logged | `send-test-events.sh checkout` | Row for `tok_demo_001` in Sheet1, `status = pending` | ✅ |
| 2 | Reminder 1 sent | Wait ~2 min after #1 | Email received (WhatsApp on a paid Twilio account) (no discount); `reminder_1_sent` filled | ✅ |
| 3 | Reminder 2 with discount | Wait ~3 more min | Email (and WhatsApp, on a paid Twilio account) mentions `COMEBACK10`; `status = reminders_complete`, `reminder_2_sent` filled | ✅ |
| 4 | Purchase stops reminders | Run #1, then `send-test-events.sh order` before 2 min | `status = recovered`; execution stops at **Still Abandoned? (1)**; no messages sent | ✅ |
| 5 | Purchase between reminders | Run #1, wait for reminder 1, then send `order` | Only reminder 1 received; reminder 2 never sent | ☐ |
| 6 | No consent | `send-test-events.sh no-consent` | Execution stops at **Has Contact + Consent?**; no row, no message | ✅ |
| 7 | No contact details | `send-test-events.sh no-contact` | Stops at **Has Contact + Consent?**; nothing logged or sent | ☐ |
| 8 | Email only (no phone) | Edit `checkout-created.json` phone to `""`, rerun #1 | Email sent; WhatsApp branch skipped; sheet still updated | ☐ |
| 9 | WhatsApp failure | Any phone on the Twilio free trial (custom WhatsApp text is blocked) | WhatsApp node errors after 3 retries but email + sheet update still run | ✅ |
| 10 | AI failure fallback | Temporarily break the OpenAI credential | Template message sent; `ai_fallback_used = true` in Prepare node output | ☐ |
| 11 | Duplicate checkout webhook | Send `checkout` twice | Single row (upsert on `checkout_id`), not two | ☐ |
| 12 | Real Shopify flow | Start checkout in dev store with test email/phone, tick marketing consent, leave | Same as #1–#3 using real Shopify payload | ☐ |

## Recorded run

Results for the ✅ rows are in [`recorded-run/RUN_LOG.md`](recorded-run/RUN_LOG.md). Row 9 passes as error handling: WhatsApp fails on the Twilio trial and email + sheet updates still run. Unticked rows were not run for this submission.
