class ChatAgreementParams {
  final String chatRoomDocRefId;
  final String userRole;

  const ChatAgreementParams({
    required this.chatRoomDocRefId,
    required this.userRole,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatAgreementParams &&
          runtimeType == other.runtimeType &&
          chatRoomDocRefId == other.chatRoomDocRefId &&
          userRole == other.userRole;

  @override
  int get hashCode => chatRoomDocRefId.hashCode ^ userRole.hashCode;
}
