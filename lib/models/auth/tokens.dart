class TokenInfo {
  final String? accessToken;  // Made nullable
  final String? refreshToken; // Made nullable
  final DateTime? accessTokenExpiry;
  final DateTime? refreshTokenExpiry;

  TokenInfo({
    this.accessToken,
    this.refreshToken,
    this.accessTokenExpiry,
    this.refreshTokenExpiry,
  });

  bool get hasAccessToken => accessToken != null && accessToken!.isNotEmpty;
  bool get hasRefreshToken => refreshToken != null && refreshToken!.isNotEmpty;
  
  bool get isAccessTokenValid => 
      hasAccessToken && 
      accessTokenExpiry != null && 
      DateTime.now().isBefore(accessTokenExpiry!);
      
  bool get isRefreshTokenValid => 
      hasRefreshToken && 
      refreshTokenExpiry != null && 
      DateTime.now().isBefore(refreshTokenExpiry!);
  
  bool get needsRefresh => 
      !isAccessTokenValid && isRefreshTokenValid;
  
  bool get needsLogin => 
      !hasAccessToken && !hasRefreshToken;
}