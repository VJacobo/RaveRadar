/// Spotify API Configuration
/// 
/// To enable Spotify integration and hear music previews:
/// 
/// 1. Go to https://developer.spotify.com/dashboard
/// 2. Create a new app (or use an existing one)
/// 3. Add 'raveradar://callback' to your app's redirect URIs
/// 4. Copy your Client ID and Client Secret
/// 5. Replace the values below with your credentials
/// 
/// Note: For production apps, store these securely (e.g., in environment variables)
/// Never commit real credentials to version control!

class SpotifyConfig {
  // Replace these with your actual Spotify app credentials
  static const String clientId = 'YOUR_SPOTIFY_CLIENT_ID_HERE';
  static const String clientSecret = 'YOUR_SPOTIFY_CLIENT_SECRET_HERE';
  
  // Redirect URI for OAuth (add this to your Spotify app settings)
  static const String redirectUri = 'raveradar://callback';
  
  // Check if credentials are configured
  static bool get isConfigured => 
    clientId != 'YOUR_SPOTIFY_CLIENT_ID_HERE' && 
    clientSecret != 'YOUR_SPOTIFY_CLIENT_SECRET_HERE';
}