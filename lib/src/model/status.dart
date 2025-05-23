class Status {
  final int? status;
  final String? message;

  Status({this.status, this.message});

  @override
  bool operator ==(covariant Status other) {
    if (identical(this, other)) return true;

    return other.status == status && other.message == message;
  }

  @override
  int get hashCode => status.hashCode ^ message.hashCode;

  @override
  String toString() => 'StatusRequest(status: $status, message: $message)';
}
