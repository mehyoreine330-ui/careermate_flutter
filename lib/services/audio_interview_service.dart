import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../core/app_config.dart';
import '../models/interview_models.dart';

/// Drives one live mock-interview session against
/// FastAPI's `/api/v1/interviews/ws/{interview_id}` WebSocket.
///
/// Wire protocol per turn (matches routers/interviews.py exactly):
///   client -> JSON text frame:   {"history": [{"speaker": ..., "text": ...}, ...]}
///   client -> binary frame:      raw audio bytes for the candidate's answer
///   server -> JSON text frame:   {"type": "turn_result", user_transcript, ai_question_text,
///                                 ai_audio_base64, feedback, is_interview_complete}
///
/// This class owns three moving parts: the socket, the microphone recorder,
/// and the TTS playback — callers only need connect / startRecording /
/// stopRecordingAndSend / dispose.
class AudioInterviewService {
  WebSocketChannel? _channel;
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  final StreamController<InterviewTurnResponse> _responseController =
      StreamController<InterviewTurnResponse>.broadcast();
  final StreamController<Object> _errorController = StreamController<Object>.broadcast();

  String? _currentRecordingPath;
  bool _isConnected = false;

  /// Emits one parsed [InterviewTurnResponse] per completed round-trip.
  Stream<InterviewTurnResponse> get responses => _responseController.stream;

  /// Emits transport-level errors (socket errors, decode failures).
  Stream<Object> get errors => _errorController.stream;

  bool get isConnected => _isConnected;

  /// Opens the WebSocket for [interviewId].
  ///
  /// NOTE: the current backend route (routers/interviews.py) does not yet
  /// enforce auth on the WS handshake — the access token is still passed
  /// as a query param here so the connection is ready the moment the
  /// backend adds verification. Track that as a follow-up on the API side.
  Future<void> connect({required String interviewId, required String accessToken}) async {
    final uri = Uri.parse('${AppConfig.wsBaseUrl}/api/v1/interviews/ws/$interviewId')
        .replace(queryParameters: {'token': accessToken});

    _channel = WebSocketChannel.connect(uri);
    _isConnected = true;

    _channel!.stream.listen(
      _handleIncomingMessage,
      onError: (Object error, StackTrace _) {
        _isConnected = false;
        _errorController.add(error);
      },
      onDone: () => _isConnected = false,
      cancelOnError: false,
    );

    // WebSocketChannel.connect() is lazy — `ready` resolves once the
    // handshake actually completes, or throws if it fails.
    await _channel!.ready;
  }

  void _handleIncomingMessage(dynamic message) {
    if (message is! String) return; // ignore stray binary frames from server
    try {
      final decoded = jsonDecode(message) as Map<String, dynamic>;
      if (decoded['type'] == 'turn_result') {
        _responseController.add(InterviewTurnResponse.fromJson(decoded));
      } else if (decoded['type'] == 'error') {
        _errorController.add(StateError(decoded['detail'] as String? ?? 'Interview session error.'));
      }
    } catch (error) {
      _errorController.add(error);
    }
  }

  /// Starts capturing the candidate's spoken answer to a temp file.
  /// Call [stopRecordingAndSend] to end capture and push it to the server.
  Future<void> startRecording() async {
    if (!await _recorder.hasPermission()) {
      throw StateError('Microphone permission was denied.');
    }

    final dir = await getTemporaryDirectory();
    _currentRecordingPath =
        '${dir.path}/careermate_answer_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, sampleRate: 44100, numChannels: 1),
      path: _currentRecordingPath!,
    );
  }

  bool get isRecordingSupported => _currentRecordingPath != null;

  /// Stops the mic capture and sends it over the socket as one turn:
  /// the JSON history frame first, then the raw audio bytes — the backend
  /// reads them off the socket in exactly that order per turn.
  Future<void> stopRecordingAndSend(List<ConversationTurn> history) async {
    final recordedPath = await _recorder.stop();
    if (recordedPath == null) {
      throw StateError('Recording failed — no audio was captured.');
    }

    final channel = _channel;
    if (channel == null || !_isConnected) {
      throw StateError('WebSocket is not connected. Call connect() first.');
    }

    final audioBytes = await File(recordedPath).readAsBytes();

    channel.sink.add(jsonEncode({
      'history': history.map((turn) => turn.toJson()).toList(),
    }));
    channel.sink.add(audioBytes);
  }

  /// Decodes and plays the base64 MP3 returned by the server for the
  /// AI's spoken question/feedback.
  Future<void> playAiAudio(String base64Audio) async {
    final bytes = base64Decode(base64Audio);
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/careermate_ai_${DateTime.now().millisecondsSinceEpoch}.mp3';
    final file = await File(path).writeAsBytes(bytes, flush: true);

    await _player.setFilePath(file.path);
    await _player.play();
  }

  Future<void> disconnect() async {
    await _channel?.sink.close();
    _isConnected = false;
  }

  Future<void> dispose() async {
    await disconnect();
    await _recorder.dispose();
    await _player.dispose();
    await _responseController.close();
    await _errorController.close();
  }
}
