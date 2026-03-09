class EcheancierRequest {
  final int clientId;
  final double montantTotal;
  final int nombreMensualites;

  EcheancierRequest({
    required this.clientId,
    required this.montantTotal,
    required this.nombreMensualites,
  });

  Map<String, dynamic> toJson() {
    return {
      "clientId": clientId,
      "montantTotal": montantTotal,
      "nombreMensualites": nombreMensualites,
    };
  }
}
