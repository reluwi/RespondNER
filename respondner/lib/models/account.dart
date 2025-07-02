class Account {
  final int id;
  final String accountType; // e.g., "Admin", "Responder"
  final String agencyName;
  final String email;
  final String name;
  final String password; // Note: In a real app, you wouldn't send passwords to the client.

  Account({
    required this.id,
    required this.accountType,
    required this.agencyName,
    required this.email,
    required this.name,
    required this.password,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] ?? 0,
      accountType: json['accountType'] ?? 'N/A',
      agencyName: json['agencyName'] ?? 'N/A',
      email: json['email'] ?? 'No Email',
      name: json['name'] ?? 'No Name',
      password: json['password'] ?? '••••••••',
    );
  }
}