import 'package:flutter/material.dart';

enum BusinessType { barber, tattoo, spa }

class Business {
  final String id;
  final String code;
  final String name;
  final String address;
  final double rating;
  final String coverImage;
  final int colorHex;
  final BusinessType type;

  // NOVO: Define se a loja pagou pela exclusividade
  final bool isPremium;

  Business({
    required this.id,
    required this.code,
    required this.name,
    required this.address,
    required this.rating,
    required this.coverImage,
    required this.colorHex,
    required this.type,
    this.isPremium = false, // Por defeito é falso
  });

  IconData get icon {
    switch (type) {
      case BusinessType.barber: return Icons.content_cut;
      case BusinessType.tattoo: return Icons.brush;
      case BusinessType.spa: return Icons.spa;
    }
  }

  String get bookingActionLabel {
    switch (type) {
      case BusinessType.barber: return "MARCAR CORTE";
      case BusinessType.tattoo: return "AGENDAR SESSÃO";
      case BusinessType.spa: return "RESERVAR MOMENTO";
    }
  }

  String get welcomeMessage {
    switch (type) {
      case BusinessType.barber: return "O teu estilo em dia.";
      case BusinessType.tattoo: return "Arte na pele.";
      case BusinessType.spa: return "Relaxa e aproveita.";
    }
  }
}

// DADOS DE TESTE
final List<Business> mockBusinesses = [
  Business(
    id: '1', code: 'barber', name: 'Barber King',
    address: 'Av. Liberdade', rating: 4.9,
    coverImage: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?q=80&w=800',
    colorHex: 0xFFFFD700, type: BusinessType.barber,
    isPremium: true, // <--- ESTE PAGA! VAI TER EXCLUSIVIDADE.
  ),
  Business(
    id: '2', code: 'ink', name: 'Ink Master',
    address: 'Bairro Alto', rating: 5.0,
    coverImage: 'https://images.unsplash.com/photo-1611558709798-e009c8fd7706?q=80&w=800',
    colorHex: 0xFFE91E63, type: BusinessType.tattoo,
    isPremium: false, // Este usa a versão normal SkillHub
  ),
  Business(
    id: '3', code: 'spa', name: 'Zen Garden',
    address: 'Cascais', rating: 4.8,
    coverImage: 'https://images.unsplash.com/photo-1600334129128-685c5582fd35?q=80&w=800',
    colorHex: 0xFF00BFFF, type: BusinessType.spa,
    isPremium: false,
  ),
];