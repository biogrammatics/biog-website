# Render Setup & Troubleshooting

## Manual Tasks for Render Deployment

### Seed Service Packages

If the service packages aren't automatically seeded during deployment, you can manually seed them from the Render shell:

1. Go to your Render dashboard
2. Navigate to your web service
3. Click on "Shell" tab
4. Run the following command:

```bash
rails service_packages:seed
```

To verify the packages were created:

```bash
rails service_packages:list
```

To force reseed (clear and recreate):

```bash
rails service_packages:reseed
```

## Expected Service Packages

After seeding, you should see 6 service packages:

1. Codon Optimization Service - $495
2. Cloning & Verification Service - $850
3. Transformation & Integration Package - $1,250
4. Colony Screening & Copy Number Service - $1,650
5. Pilot Expression Study - $2,400
6. Protein Analysis Service - $950

**Total value: $7,595**

## Troubleshooting

### 404 Error on /protein_pathway/step/1

**Symptom**: Landing page loads but clicking "Start Building Your Path" gives 404
**Cause**: Service packages table is empty
**Solution**: Run `rails service_packages:seed` from Render shell

### Check Build Logs

Look for this section in your Render build logs:
```
=== Seeding service packages ===
Seeding service packages...
✓ Successfully seeded 6 service packages
```

If you see "Service packages already exist", the data is already there.

## Environment Variables Required

Make sure these are set in Render:
- `SECRET_KEY_BASE` - Rails secret key
- `DATABASE_URL` - Auto-configured by Render
- `RAILS_ENV=production` - Auto-configured by Render
