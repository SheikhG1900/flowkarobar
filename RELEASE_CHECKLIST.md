# Google Play Store Release Checklist

## ✅ Critical Issues to Fix Before Release

### 1. **App Signing Configuration** ⚠️ REQUIRED

Your app is currently using debug signing for release builds. This **MUST** be fixed before uploading to Google Play Store.

#### Steps to Fix:

1. **Generate a Keystore** (if you don't have one):
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   - Store this file securely (you'll need it for all future updates)
   - Remember the passwords you set

2. **Create `android/key.properties` file** (DO NOT commit this to git):
   ```properties
   storePassword=<your-keystore-password>
   keyPassword=<your-key-password>
   keyAlias=upload
   storeFile=<path-to-your-keystore-file>
   ```
   Example:
   ```properties
   storePassword=your_secure_password
   keyPassword=your_secure_password
   keyAlias=upload
   storeFile=../upload-keystore.jks
   ```

3. **Add `key.properties` to `.gitignore`**:
   ```
   android/key.properties
   *.jks
   upload-keystore.jks
   ```

4. **Verify the build.gradle is updated** (already done):
   - The build.gradle now checks for `key.properties` and uses it for release signing
   - If the file doesn't exist, it falls back to debug (for development only)

### 2. **Premium Purchase Products Setup** ⚠️ REQUIRED

Your app has premium purchase functionality implemented, but you need to configure the products in Google Play Console.

#### Product IDs in Your Code:
- `flowpaisa_premium_monthly` - Monthly subscription
- `flowpaisa_premium_yearly` - Yearly subscription  
- `flowpaisa_premium_lifetime` - One-time purchase

#### Steps to Configure in Google Play Console:

1. **Go to Google Play Console** → Your App → Monetize → Products → Subscriptions/In-app products

2. **Create the Products**:
   - **Monthly Subscription** (`flowpaisa_premium_monthly`):
     - Type: Subscription
     - Base plan: Monthly recurring
     - Set your price
   
   - **Yearly Subscription** (`flowpaisa_premium_yearly`):
     - Type: Subscription
     - Base plan: Yearly recurring
     - Set your price
   
   - **Lifetime Purchase** (`flowpaisa_premium_lifetime`):
     - Type: In-app product (one-time purchase)
     - Set your price

3. **Activate the Products**:
   - Make sure all products are in "Active" status
   - Products must be active before they can be purchased

4. **Test Purchases**:
   - Add test accounts in Google Play Console → Setup → License testing
   - Test purchases won't be charged to test accounts

### 3. **Build .aab File**

Once signing is configured, build the app bundle:

```bash
flutter build appbundle --release
```

The output will be at: `build/app/outputs/bundle/release/app-release.aab`

### 4. **Pre-Release Testing Checklist**

- [ ] Test premium purchase flow with test accounts
- [ ] Verify restore purchases works correctly
- [ ] Test subscription expiry handling
- [ ] Verify all premium features are properly gated
- [ ] Test on multiple Android versions
- [ ] Verify app works without premium (free tier limits)

### 5. **Google Play Console Requirements**

Before uploading, ensure you have:

- [ ] App icon (1024x1024px)
- [ ] Feature graphic (1024x500px)
- [ ] Screenshots (at least 2, up to 8)
- [ ] Privacy Policy URL (required for apps with in-app purchases)
- [ ] Content rating completed
- [ ] Store listing information (description, etc.)

### 6. **Important Notes**

⚠️ **Security**: Never commit your keystore file or `key.properties` to version control!

⚠️ **Backup**: Keep a secure backup of your keystore file. If you lose it, you cannot update your app on Play Store.

⚠️ **Product IDs**: The product IDs in your code must exactly match the product IDs in Google Play Console.

⚠️ **Testing**: Always test purchases in a test environment before going live.

## Current Status

✅ Premium purchase code is implemented and ready
✅ Product IDs are defined in code
✅ Purchase flow, restore, and verification are implemented
✅ BILLING permission added to AndroidManifest.xml
⚠️ **Action Required**: Configure signing for release builds
⚠️ **Action Required**: Create and activate products in Google Play Console

## Next Steps

1. Generate keystore and create `key.properties`
2. Create products in Google Play Console
3. Test purchases with test accounts
4. Build .aab file
5. Upload to Play Console
