library text_to_speech_api;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

const BASE_URL = 'https://texttospeech.googleapis.com/v1/';
var client = http.Client();

/* class FileService {
  static Future<String> get _localPath async {
    // Returns the path to the system's temporary directory
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  static Future<File> createAndWriteFile(String filePath, content) async {
    // Creates a new file in the temporary directory and writes the given content to it
    final path = await _localPath;
    final file = File('$path/$filePath');
    await file.writeAsBytes(content);
    return file;
  }
} */

class AudioResponse {
  final String? audioContent;

  AudioResponse(this.audioContent);

  AudioResponse.fromJson(Map<String, dynamic> json)
      : audioContent = json['audioContent'];
}

class TextToSpeechService {
  String? _apiKey;

  TextToSpeechService([this._apiKey]);

/*   Future<File> _createMp3File(AudioResponse response) async {
    // Creates an MP3 file from the given audio response
    String id = new DateTime.now().millisecondsSinceEpoch.toString();
    String fileName = '$id.mp3';

    // Decodes the audio content to binary format and creates an MP3 file
    var bytes = base64.decode(response.audioContent!);
    return FileService.createAndWriteFile(fileName, bytes);
  } */

  _getApiUrl(String endpoint) {
    // Returns the API URL for the given endpoint
    return Uri.parse('$BASE_URL$endpoint?key=$_apiKey');
  }

  Future<dynamic> textToSpeech({
    required String text,

    /// Voice name.
    ///
    /// See https://cloud.google.com/text-to-speech/docs/voices for more info.
    String voiceName = 'de-DE-Wavenet-D',

    /// Country language code.
    ///
    /// See https://cloud.google.com/text-to-speech/docs/voices for more info.
    String audioEncoding = 'MP3',

    /// Country language code.
    ///
    /// See https://cloud.google.com/text-to-speech/docs/voices for more info.
    String languageCode = 'de-DE',

    /// Pitch the voice.
    ///
    /// Ranges from -20 to 20.
    double pitch = 0.0,
    double speakingRate = 1.0,
  }) async {
    // Converts text to speech
    const endpoint = 'text:synthesize';

    // Constructs the request body
    final bodyMap = <String, dynamic>{
      "input": {
        "text": text,
      },
      "voice": {
        "languageCode": languageCode,
        "name": voiceName,
      },
      "audioConfig": {
        "audioEncoding": audioEncoding,
        "pitch": pitch,
        "speakingRate": speakingRate,
      },
    };

    final request = await client.post(_getApiUrl(endpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(bodyMap));

    try {
      // Send the request and get the response
      final response = request;
      if (response.statusCode == 200) {
        if (kIsWeb) {
          return jsonDecode(response.body);
        }
        return '';
      }
    } catch (e) {
      // Catch any errors that occur while sending the request or processing the response
      throw (e);
    }
  }
}
