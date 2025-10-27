# Next Steps: Completing the "Your Path to Protein" Funnel

## Current Status
✅ Database migrations created (not yet run)
✅ Models created (ServicePackage, PathwaySelection, ServiceQuote)
✅ Seed data prepared for 6 service packages
✅ Environment-specific credentials structure set up

❌ Need to add Twilio credentials to development
❌ Need to run migrations
❌ Need to build controllers and views

---

## Problem: Encryption Keys

Rails commands are failing because the development credentials file doesn't have Twilio credentials yet.

### What You Need to Do:

1. **Open your Mac Terminal**

2. **Run this command:**
   ```bash
   cd /Users/studio/Claude/biog_website
   EDITOR="nano" RAILS_ENV=development rails credentials:edit
   ```

3. **When nano opens, add this at the TOP of the file:**
   ```yaml
   twilio:
     account_sid: "YOUR_TWILIO_ACCOUNT_SID"
     auth_token: "YOUR_TWILIO_AUTH_TOKEN"
     phone_number: "+15555551234"

   ```
   (Use your actual Twilio credentials from console.twilio.com)

4. **Save:** Press Ctrl+X, then Y, then Enter

5. **Verify it worked:**
   ```bash
   RAILS_ENV=development rails credentials:show | grep -A3 twilio
   ```
   You should see your twilio credentials printed.

---

## After Credentials Are Fixed:

Once Twilio credentials are added, run these commands:

```bash
# Run the migrations
rails db:migrate

# Seed the service packages
rails runner db/seeds/service_packages.rb

# Verify it worked
rails console
# In console, type: ServicePackage.count
# Should show: 6
```

---

## What's Been Built So Far:

### Database Tables Created:
- **service_packages** - 6 service offerings (Codon Optimization, Cloning, etc.)
- **pathway_selections** - Track user choices through the funnel
- **service_quotes** - Capture quote requests with lead data

### Models Created:
- `ServicePackage` - with validations and scopes
- `PathwaySelection` - tracks DIY vs Service choices per step
- `ServiceQuote` - lead capture with quote number generation

### Seed Data Ready:
6 service packages with pricing:
1. Codon Optimization - $495
2. Cloning & Verification - $850
3. Transformation & Integration - $1,250
4. Colony Screening - $1,650
5. Pilot Expression Study - $2,400
6. Protein Analysis - $950

Full-service package value: **$7,595**

---

## Still Need to Build:

1. **ProteinPathwayController** - handles the interactive 6-step flow
2. **Pathway Views** - interactive step selection UI
3. **Quote Request Form** - lead capture
4. **Routes** - connect everything
5. **Homepage Integration** - add "Your Path to Protein" CTA
6. **Product Page Upsells** - service suggestions on vector/strain pages
7. **Cart Upsells** - service add-ons during checkout

---

## When You Come Back:

Tell Claude: "I've added the Twilio credentials. Let's continue building the protein pathway funnel."

Then we can run migrations and continue building the interactive UI.
