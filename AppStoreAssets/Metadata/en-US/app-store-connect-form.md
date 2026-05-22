# App Store Connect Form Values

Use these values for the App Store Connect record for DamageScope AI.

## App Information

- Name: `DamageScope AI`
- Subtitle: `AI damage reports`
- Bundle ID: `com.damagescopeai.app`
- SKU: `DAMAGESCOPEAI-IOS-001`
- Primary Language: `English`
- Category: `Business`
- Secondary Category: `Productivity`
- Content Rights: `No, it does not contain, show, or access third-party content`
- User Access: `Full Access`

## Pricing And Availability

- App price: `Free`
- Availability: `All Countries or Regions`
- Distribution method: `Public Distribution`
- Pre-order: `No`
- Volume purchase/education discount: `No`

The subscriptions carry the paid pricing. If App Store Connect requires a paid-app agreement for subscription setup, complete Tax and Banking first.

## Version Information

- Version: `1.0`
- Copyright: `2026 lanray07`
- App Store icon: `AppStoreAssets/AppIcon/DamageScopeAI-AppIcon-1024.png`
- iPhone screenshots: `AppStoreAssets/Screenshots/iPhone-6.9`
- iPad screenshots: `AppStoreAssets/Screenshots/iPad-13`

### Promotional Text

Document damage faster with organised photo evidence, AI-assisted visual findings, repair priorities, and client-ready PDF reports.

### Description

DamageScope AI helps contractors, landlords, property managers, roofers, fleet managers, restoration businesses, and insurance support teams document damage clearly and reduce paperwork.

Create damage cases, capture or upload photo evidence, organise images by area, review cautious AI-assisted findings, build repair priority lists, and export client-ready PDF reports with disclaimers and signature placeholders.

AI findings are visual suggestions only. DamageScope AI does not provide insurance advice, legal advice, structural certification, repair cost guarantees, or safety clearance. All findings should be reviewed by qualified professionals.

### Keywords

`property damage,roof damage,storm damage,repair report,contractor,landlord,maintenance,photo evidence,water leak,mould`

### Support URL

`https://github.com/lanray07/DamageScope-AI/blob/main/AppStoreAssets/Metadata/en-US/support.md`

### Marketing URL

Leave blank unless you have a public marketing website.

### Privacy Policy URL

`https://github.com/lanray07/DamageScope-AI/blob/main/AppStoreAssets/Metadata/en-US/privacy-policy.md`

## Age Rating Questionnaire

Recommended answers for the current build:

- Profanity or crude humor: `None`
- Mature or suggestive themes: `None`
- Alcohol, tobacco, drug use or references: `None`
- Medical or treatment information: `None`
- Horror or fear themes: `None`
- Cartoon or fantasy violence: `None`
- Realistic violence: `None`
- Sexual content or nudity: `None`
- Gambling or contests: `None`
- Unrestricted web access: `No`
- User-generated content shared publicly: `No`
- Messaging or chat: `No`
- Advertising: `No`
- App enables purchases: `Yes`, subscriptions through Apple In-App Purchase

Expected rating: `4+`.

## App Privacy

Recommended answer for the current mock-AI build:

- Do you or your third-party partners collect data from this app? `No`

Reason: the current app stores cases, photos, findings, and reports locally on device, uses mock AI by default, has no analytics SDK, has no account system, and does not send user content to a developer backend.

Important: if you later enable `RemoteAIService` in production and transmit photos, notes, case details, or identifiers to a backend, update App Privacy before release. In that future mode, declare the appropriate data types, likely `User Content` and any identifiers/contact details you collect.

## Export Compliance

- Uses non-exempt encryption: `No`
- Notes: the app does not implement proprietary encryption. It uses Apple platform frameworks and may use standard HTTPS for the secure backend placeholder.

The app plist includes `ITSAppUsesNonExemptEncryption = false`.

## App Review Information

### Contact

- First name: `Lanray`
- Last name: `Banks`
- Email: `lanraybanks@gmail.com`
- Phone: use your App Store Connect account phone number

### Demo Account

- Sign-in required: `No`
- Demo account: leave blank

### Notes

Mock AI mode is enabled by default. The reviewer can create a damage case, add or upload a photo, run the AI scan workflow, approve findings, generate repair priorities, and export a PDF report without a backend account.

DamageScope AI displays clear disclaimers that AI findings are visual suggestions only and are not insurance advice, legal advice, structural certification, repair cost guarantees, or safety clearance.

## Subscription Group

- Group reference name: `DamageScope AI Plans`
- Subscription group display name: `DamageScope AI Plans`

## Subscriptions

### Pro Monthly

- Reference name: `Pro Monthly`
- Product ID: `com.damagescopeai.pro.monthly`
- Duration: `1 Month`
- Price: `GBP 24.99`
- Display name: `DamageScope AI Pro`
- Description: `Unlimited cases, 250 AI scans per month, professional PDF reports, repair priority lists, and custom branding placeholder.`

### Pro Yearly

- Reference name: `Pro Yearly`
- Product ID: `com.damagescopeai.pro.yearly`
- Duration: `1 Year`
- Price: `GBP 199.99`
- Display name: `DamageScope AI Pro Yearly`
- Description: `Annual Pro access with professional reports, repair priority lists, and custom branding placeholder.`

### Business Monthly

- Reference name: `Business Monthly`
- Product ID: `com.damagescopeai.business.monthly`
- Duration: `1 Month`
- Price: `GBP 89.99`
- Display name: `DamageScope AI Business`
- Description: `Unlimited scans and reports, advanced branding placeholder, multi-property and fleet support, contractor action lists, and team workflow placeholder.`

## Build

Upload from Xcode on macOS:

- Scheme: `DamageScopeAI`
- Bundle ID: `com.damagescopeai.app`
- Version: `1.0`
- Build: `1`

After the build processes in App Store Connect, select it under the `1.0` version page before submitting for review.
