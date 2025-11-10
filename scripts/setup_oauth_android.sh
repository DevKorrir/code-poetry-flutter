#!/bin/bash

# Script to automatically configure Android OAuth deep links
# This extracts your Firebase project ID and updates AndroidManifest.xml

echo "🔧 Setting up Android OAuth deep links..."

# Find Firebase project ID from google-services.json
if [ -f "android/app/google-services.json" ]; then
    PROJECT_ID=$(grep -o '"project_id"[[:space:]]*:[[:space:]]*"[^"]*"' android/app/google-services.json | cut -d'"' -f4)
    
    if [ -z "$PROJECT_ID" ]; then
        echo "❌ Could not extract project_id from google-services.json"
        exit 1
    fi
    
    echo "✅ Found Firebase project ID: $PROJECT_ID"
    
    # Update AndroidManifest.xml with correct Firebase host
    MANIFEST_PATH="android/app/src/main/AndroidManifest.xml"
    
    if [ -f "$MANIFEST_PATH" ]; then
        # Replace placeholder with actual project ID
        sed -i.bak -E "s/[a-zA-Z0-9-]+\.firebaseapp\.com/$PROJECT_ID.firebaseapp.com/g" "$MANIFEST_PATH"
        
        echo "✅ Updated AndroidManifest.xml with Firebase host: $PROJECT_ID.firebaseapp.com"
        echo ""
        echo "📱 Next steps:"
        echo "1. Run: flutter clean"
        echo "2. Run: flutter run"
        echo "3. Test GitHub sign-in"
        echo ""
        echo "🎉 OAuth deep links configured!"
    else
        echo "❌ AndroidManifest.xml not found at $MANIFEST_PATH"
        exit 1
    fi
else
    echo "❌ google-services.json not found"
    echo "Please download it from Firebase Console and place it in android/app/"
    exit 1
fi
