// ignore_for_file: unnecessary_new

import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

import 'schema/room.dart';

const int KEY_LENGTH = 32;
const int IV_LENGTH = 12;
const int TAG_LENGTH = 16;
const int SALT_LENGTH = 16;
const int KEY_ITERATIONS_COUNT = 10000;

class Aes256Gcm {
  /// Encrypts passed [cleartext] with key generated based on [password] argument
  static Future<String> encrypt(Room r, String cleartext) async {
    final iv = r.iv;
    final key = SecretKey(r.password);
    final algorithm = AesGcm.with256bits();

    final secretBox = await algorithm.encrypt(
      utf8.encode(cleartext),
      secretKey: key,
      nonce: iv,
    );

    final List<int> result = secretBox.cipherText + secretBox.mac.bytes;

    return base64.encode(result);
  }

  /// Decrypts passed [ciphertext] with key generated based on [password] argument
  static Future<String> decrypt(Room r, String cipherText) async {
    final cText = base64.decode(cipherText);
    final iv = r.iv;
    final key = SecretKey(r.password);
    Uint8List text = cText.sublist(0, cText.length - 16);
    Uint8List mac = cText.sublist(cText.length - 16);
    final algorithm = AesGcm.with256bits();
    final secretBox = new SecretBox(text, nonce: iv, mac: new Mac(mac));

    final cleartext = await algorithm.decrypt(
      secretBox,
      secretKey: key,
    );

    return utf8.decode(cleartext);
  }
}
