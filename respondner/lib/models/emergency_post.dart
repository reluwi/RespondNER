class EmergencyPost {
  final String timestamp;
  final String extractedPost;
  final String namedEntities;

  EmergencyPost({
    required this.timestamp,
    required this.extractedPost,
    required this.namedEntities,
  });

  factory EmergencyPost.fromJson(Map<String, dynamic> json) {
    return EmergencyPost(
      timestamp: json['timestamp'] ?? 'N/A',
      extractedPost: json['extractedPost'] ?? 'No content',
      namedEntities: json['namedEntities'] ?? 'N/A',
    );
  }
}