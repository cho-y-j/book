abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // Simplified connectivity check
    try {
      return true;
    } catch (_) {
      return false;
    }
  }
}
