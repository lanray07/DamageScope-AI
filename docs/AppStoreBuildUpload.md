# App Store Build Upload

This repository includes a manual GitHub Actions workflow for archiving DamageScope AI with Xcode on a macOS runner, exporting an App Store IPA, and uploading it to App Store Connect.

## Required GitHub Secrets

Add these in GitHub under **Settings > Secrets and variables > Actions > Repository secrets**:

- `APP_STORE_CONNECT_API_KEY_ID`: App Store Connect API key ID.
- `APP_STORE_CONNECT_API_ISSUER_ID`: App Store Connect issuer ID.
- `APP_STORE_CONNECT_API_PRIVATE_KEY`: The `.p8` private key contents, either pasted as-is or base64 encoded.
- `APPLE_TEAM_ID`: Apple Developer Team ID.

Use a team App Store Connect API key with sufficient permissions for App Store upload and provisioning. Keep the `.p8` private key out of the repository.

## Run The Upload

1. Open GitHub Actions.
2. Select **iOS App Store Upload**.
3. Click **Run workflow**.
4. Leave **Upload the exported IPA to App Store Connect** enabled.
5. Optionally enter a build number. If blank, the workflow uses the GitHub run number.

After the upload completes, App Store Connect may take several minutes to process the build. Once processing finishes, return to the iOS `1.0` version page and select the processed build in the **Build** section before adding the app version for review.

## What The Workflow Does

- Uses the shared `DamageScopeAI` Xcode scheme.
- Archives the Release build for generic iOS devices.
- Uses automatic signing with `APPLE_TEAM_ID`.
- Exports an App Store Connect IPA.
- Uploads the IPA with `xcrun altool` and the App Store Connect API key.
- Stores the exported IPA and Xcode logs as short-lived workflow artifacts.
