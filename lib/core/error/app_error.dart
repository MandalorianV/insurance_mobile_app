enum AppError {
  noInternet,
  timeout,
  serverError,
  unknown;

  String get message => switch (this) {
    AppError.noInternet => 'İnternet bağlantısı yok',
    AppError.timeout => 'Bağlantı zaman aşımına uğradı',
    AppError.serverError => 'Sunucu hatası, lütfen tekrar deneyin',
    AppError.unknown => 'Bir hata oluştu, lütfen tekrar deneyin',
  };
}
