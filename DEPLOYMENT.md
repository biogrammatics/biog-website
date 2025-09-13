# Deployment Instructions for Render

## Prerequisites

1. Create a Render account at https://render.com
2. Connect your GitHub repository to Render

## Environment Variables to Set in Render

After creating your web service in Render, you need to set these environment variables:

### Required Variables:

1. **RAILS_MASTER_KEY**
   - Get this from `config/master.key` file (DO NOT commit this file)
   - This is required for Rails to decrypt credentials
   
2. **RAILS_ENV**
   - Set to: `production`

3. **RENDER_FIRST_DEPLOY** (optional)
   - Set to: `true` for the first deployment only
   - This will seed the database with initial data
   - Remove or set to `false` after first successful deployment

### Optional Variables (already configured in render.yaml):

- **DATABASE_URL** - Automatically set by Render when database is created
- **WEB_CONCURRENCY** - Set to 2 (number of Puma workers)
- **RAILS_MAX_THREADS** - Set to 5 (threads per worker)

## Deployment Steps

### First-time Setup:

1. **Push code to GitHub**
   ```bash
   git add .
   git commit -m "Configure for Render deployment"
   git push origin main
   ```

2. **Create New Web Service in Render**
   - Go to your Render dashboard
   - Click "New +" → "Web Service"
   - Connect your GitHub repository
   - Select the branch (usually `main`)
   - Render will auto-detect Rails and use the `render.yaml` configuration

3. **Set Environment Variables**
   - Go to your service's Environment tab
   - Add the required variables listed above
   - Make sure to add your RAILS_MASTER_KEY

4. **Deploy**
   - Render will automatically deploy when you push to GitHub
   - First deployment will:
     - Install dependencies
     - Create database
     - Run migrations
     - Seed initial data (if RENDER_FIRST_DEPLOY=true)
     - Start the application

5. **After First Deployment**
   - Remove or set `RENDER_FIRST_DEPLOY=false` to prevent re-seeding

### Subsequent Deployments:

Simply push to GitHub:
```bash
git push origin main
```

Render will automatically:
- Pull the latest code
- Install any new dependencies
- Run database migrations
- Precompile assets
- Restart the application

## Database Management

### Access Rails Console in Production:
```bash
# In Render dashboard, go to Shell tab and run:
bundle exec rails console
```

### Run Migrations Manually:
```bash
# In Render Shell:
bundle exec rails db:migrate
```

### Reset Database (CAUTION - destroys all data):
```bash
# In Render Shell:
bundle exec rails db:drop db:create db:migrate db:seed
```

## Monitoring

- Check the **Logs** tab in Render dashboard for application logs
- Monitor the **Metrics** tab for performance data
- Set up **Health Checks** to ensure uptime

## Troubleshooting

### Common Issues:

1. **Assets not loading**
   - Ensure `bundle exec rails assets:precompile` runs in build script
   - Check that RAILS_MASTER_KEY is set correctly

2. **Database connection errors**
   - Verify DATABASE_URL is set (should be automatic)
   - Check that PostgreSQL service is running

3. **Application crashes on startup**
   - Check logs for specific error messages
   - Verify all environment variables are set
   - Ensure master.key is correct

4. **Migrations fail**
   - Check for PostgreSQL-specific syntax if migrating from SQLite
   - Run migrations manually in Shell if needed

## Custom Domain

To add a custom domain:
1. Go to Settings → Custom Domains
2. Add your domain
3. Update your DNS records as instructed by Render

## SSL Certificate

Render provides free SSL certificates automatically for all services.

## Backup Strategy

Consider setting up regular database backups:
- Render provides automatic daily backups on paid plans
- For free tier, consider manual exports or third-party backup solutions

## Support

- Render Documentation: https://render.com/docs
- Rails on Render Guide: https://render.com/docs/deploy-rails
- Support: https://render.com/support# Deployment trigger - Fri Sep 12 17:19:35 PDT 2025
