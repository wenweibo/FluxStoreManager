class EventExpiredCookie {
  const EventExpiredCookie({this.isRequiredLogin = false, this.errMsg});
  final bool isRequiredLogin;
  final String? errMsg;
}
