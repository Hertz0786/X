import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:kotlin/api/client/id_storage.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _connected = false;

  bool get isConnected => _connected;

  Future<void> connect() async {
    if (_connected || _socket != null) return;

    final userId = await IdStorage.getUserId();
    if (userId == null) {
      print("❌ Không có userId để kết nối socket");
      return;
    }

    _socket = IO.io('http://10.0.2.2:5000', <String, dynamic>{
      'transports': ['websocket'],
      'query': {'userId': userId},
    });

    _socket!.onConnect((_) {
      _connected = true;
      print('✅ Đã kết nối Socket.IO');
    });

    _socket!.onDisconnect((_) {
      _connected = false;
      print('❌ Socket.IO bị ngắt kết nối');
    });

    _socket!.onConnectError((data) {
      print('⚠️ Lỗi kết nối socket: $data');
    });

    _socket!.onError((data) {
      print('❌ Lỗi tổng quát từ socket: $data');
    });
  }

  void onNewMessage(void Function(dynamic data) callback) {
    if (_socket != null) {
      _socket!.on('newMessage', callback);
    } else {
      print("⚠️ Socket chưa được khởi tạo để lắng nghe newMessage");
    }
  }

  void sendMessage(String receiverId, String text, {String? imageUrl}) {
    if (!_connected || _socket == null) {
      print("⚠️ Không thể gửi tin nhắn: socket chưa kết nối");
      return;
    }

    _socket!.emit('sendMessage', {
      'receiverId': receiverId,
      'text': text,
      'image': imageUrl,
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _connected = false;
    _socket = null;
  }
}
