class Shop {
  final int id;
  final String name;
  final String address;
  final String description;
  final List<String>? imageUrls;

  Shop({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    this.imageUrls,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      description: json['description'],
      imageUrls: json['imageFiles'] != null
          ? List<String>.from(json['imageFiles'].map((file) => file['url']))
          : null,
    );
  }
}