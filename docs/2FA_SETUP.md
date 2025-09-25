# Two-Factor Authentication Setup Guide

## Overview
This application supports two-factor authentication (2FA) using both TOTP (Time-based One-Time Passwords) and SMS verification.

- **Customers**: 2FA is optional but recommended
- **Administrators**: 2FA is REQUIRED

## Features Implemented

### Authentication Methods
1. **TOTP (Authenticator Apps)**
   - Works with Google Authenticator, Authy, 1Password, etc.
   - QR code generation for easy setup
   - Manual secret key entry option
   - Most secure option

2. **SMS Verification**
   - Sends 6-digit codes via text message
   - Requires phone number verification
   - Uses Twilio for SMS delivery

### Additional Security Features
- **Backup Codes**: 10 single-use recovery codes generated during setup
- **Rate Limiting**: Prevents brute force attacks on verification endpoints
- **Encrypted Storage**: All sensitive 2FA data is encrypted in the database
- **Admin Enforcement**: Administrators cannot disable 2FA once enabled

## Configuration Required

### 1. Set Up Rails Credentials

First, create your Rails credentials file if it doesn't exist:

```bash
EDITOR="code --wait" rails credentials:edit
```

Or use your preferred editor:
```bash
EDITOR="vim" rails credentials:edit
```

### 2. Add Twilio Credentials

Add the following to your credentials file:

```yaml
twilio:
  account_sid: your_twilio_account_sid_here
  auth_token: your_twilio_auth_token_here
  phone_number: "+1234567890"  # Your Twilio phone number with country code
```

### 3. Get Twilio Credentials

1. Sign up for a Twilio account at https://www.twilio.com
2. Get your Account SID and Auth Token from the Twilio Console
3. Purchase a phone number capable of sending SMS
4. Add these credentials to your Rails credentials file

### 4. Test SMS Functionality (Optional)

For development/testing without real SMS:
- Set Twilio credentials to test values
- SMS codes will be logged to Rails logger instead of sent

## Usage

### For Users

1. **Enable 2FA**:
   - Go to Account → Security
   - Click "Enable 2FA"
   - Choose TOTP or SMS method
   - Follow setup instructions

2. **Login with 2FA**:
   - Enter email and password as usual
   - Enter 6-digit code from authenticator app or SMS
   - Or use a backup code if needed

3. **Manage 2FA**:
   - View/regenerate backup codes
   - Switch between TOTP and SMS
   - Disable 2FA (customers only)

### For Administrators

1. **First Login**:
   - Admins will be prompted to set up 2FA on first login
   - 2FA cannot be disabled once enabled for admin accounts

2. **Managing Users**:
   - View 2FA status for all users in admin panel
   - Cannot force 2FA for customers (optional for them)

## Database Schema

The following fields were added to the users table:

- `otp_secret`: Encrypted TOTP secret key
- `otp_required_for_login`: Boolean flag for 2FA requirement
- `phone_number`: User's phone number for SMS
- `phone_verified`: Phone verification status
- `otp_delivery_method`: 'totp' or 'sms'
- `two_factor_enabled`: Overall 2FA status
- `two_factor_confirmed_at`: When 2FA was set up
- `otp_backup_codes`: Encrypted JSON array of backup codes
- `otp_code`: Temporary SMS code (encrypted)
- `otp_code_sent_at`: When SMS code was sent

## Security Considerations

1. **Rate Limiting**: All verification endpoints are rate-limited to prevent brute force
2. **Code Expiry**: SMS codes expire after 10 minutes
3. **TOTP Drift**: Allows 30-second drift for time sync issues
4. **Backup Codes**: Single-use only, should be stored securely by user
5. **Encryption**: All sensitive 2FA data is encrypted at rest

## Testing 2FA

### Manual Testing Steps

1. **Create a test admin user**:
   ```ruby
   User.create!(
     email_address: "admin@test.com",
     password: "password123",
     admin: true,
     first_name: "Admin",
     last_name: "User"
   )
   ```

2. **Test TOTP Setup**:
   - Login as the admin
   - You'll be required to set up 2FA
   - Choose authenticator app
   - Scan QR code with Google Authenticator
   - Enter code to verify

3. **Test SMS Setup** (requires Twilio credentials):
   - Choose SMS option
   - Enter phone number
   - Verify code sent via SMS

4. **Test Backup Codes**:
   - Save generated backup codes
   - Logout and login again
   - Use backup code instead of regular code

## Troubleshooting

### Common Issues

1. **"Invalid code" errors**:
   - Check device time sync for TOTP
   - Verify SMS delivery with Twilio logs
   - Ensure code hasn't expired (10 min for SMS)

2. **SMS not received**:
   - Check Twilio credentials
   - Verify phone number format (+1 for US)
   - Check Twilio account balance

3. **Admin can't disable 2FA**:
   - This is by design for security
   - Only customer accounts can disable 2FA

## Future Enhancements

Consider adding:
- WebAuthn/FIDO2 support for hardware keys
- Remember device feature
- Email-based 2FA as fallback
- Admin ability to reset user's 2FA
- Audit log for 2FA events