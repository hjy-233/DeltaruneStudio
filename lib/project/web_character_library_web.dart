// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

const _cookieName = 'deltarune_studio_characters';
const _cookieMaxAge = 60 * 60 * 24 * 365 * 5;

String? readWebCharacterLibraryCookie() {
  final cookies = html.document.cookie ?? '';
  for (final cookie in cookies.split(';')) {
    final separator = cookie.indexOf('=');
    if (separator <= 0) {
      continue;
    }
    final name = cookie.substring(0, separator).trim();
    if (name == _cookieName) {
      return Uri.decodeComponent(cookie.substring(separator + 1));
    }
  }
  return null;
}

void writeWebCharacterLibraryCookie(String value) {
  final encoded = Uri.encodeComponent(value);
  html.document.cookie =
      '$_cookieName=$encoded; path=/; max-age=$_cookieMaxAge; SameSite=Lax';
}
