class PaiementRequest {
  final String photoRecuPath;

  PaiementRequest({required this.photoRecuPath});

  Map<String, dynamic> toJson() {
    return {
      "photoRecuPath": photoRecuPath,
    };
  }
}
