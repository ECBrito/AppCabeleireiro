import 'package:flutter/material.dart';

enum BusinessType { barber, tattoo, spa }

class Business {
  final String id;
  final String code; // O código que o cliente digita (ex: 'barber')
  final String name;
  final String coverImage;
  final int colorHex; // A cor da marca
  final BusinessType type;

  Business({
    required this.id, required this.code, required this.name,
    required this.coverImage, required this.colorHex, required this.type,
  });

  IconData get icon {
    switch (type) {
      case BusinessType.barber: return Icons.content_cut;
      case BusinessType.tattoo: return Icons.brush;
      case BusinessType.spa: return Icons.spa;
    }
  }
}

// DADOS DE TESTE (A TUA "BASE DE DADOS" FAKE)
final List<Business> mockBusinesses = [
  Business(
    id: '1', code: 'barber', name: 'Barber King', 
    coverImage: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?q=80&w=800',
    colorHex: 0xFFFFD700, type: BusinessType.barber // Dourado
  ),
  Business(
    id: '2', code: 'ink', name: 'Ink Master Studio', 
    coverImage: 'https://images.unsplash.com/photo-1611558709798-e009c8fd7706?q=80&w=800',
    colorHex: 0xFFE91E63, type: BusinessType.tattoo // Rosa/Vermelho
  ),
  Business(
    id: '3', code: 'spa', name: 'Zen Garden', 
    coverImage: 'https://images.unsplash.com/photo-1600334129128-685c5582fd35?q=80&w=800',
    colorHex: 0xFF00BFFF, type: BusinessType.spa // Azul
  ),
];