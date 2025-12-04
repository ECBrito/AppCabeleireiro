import 'package:flutter/material.dart';

enum BusinessType { barber, tattoo, spa }

class Business {
  final String id;
  final String code;
  final String name;
  final String coverImage;
  final int colorHex;
  final BusinessType type;
  
  // --- CAMPOS QUE FALTAVAM ---
  final String address;
  final double rating;

  Business({
    required this.id,
    required this.code,
    required this.name,
    required this.coverImage,
    required this.colorHex,
    required this.type,
    required this.address, // Obrigatório
    required this.rating,  // Obrigatório
  });

  // Ícone dinâmico
  IconData get icon {
    switch (type) {
      case BusinessType.barber: return Icons.content_cut;
      case BusinessType.tattoo: return Icons.brush;
      case BusinessType.spa: return Icons.spa;
    }
  }

  // Texto do Botão Dinâmico
  String get bookingActionLabel {
    switch (type) {
      case BusinessType.barber: return "MARCAR CORTE";
      case BusinessType.tattoo: return "AGENDAR SESSÃO";
      case BusinessType.spa: return "RESERVAR MOMENTO";
    }
  }
  
  // Texto de Boas-vindas
  String get welcomeMessage {
    switch (type) {
      case BusinessType.barber: return "O teu estilo em dia.";
      case BusinessType.tattoo: return "Arte na pele.";
      case BusinessType.spa: return "Relaxa e aproveita.";
    }
  }
}

// --- DADOS DE TESTE ATUALIZADOS (COM MORADA E RATING) ---
final List<Business> mockBusinesses = [
  Business(
    id: '1', code: 'barber', name: 'Barber King', 
    coverImage: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?q=80&w=800',
    colorHex: 0xFFFFD700, type: BusinessType.barber,
    address: 'Av. da Liberdade, 100', // <--- ADICIONADO
    rating: 4.9, // <--- ADICIONADO
  ),
  Business(
    id: '2', code: 'ink', name: 'Ink Master', 
    coverImage: 'https://images.unsplash.com/photo-1611558709798-e009c8fd7706?q=80&w=800',
    colorHex: 0xFFE91E63, type: BusinessType.tattoo,
    address: 'Bairro Alto, Travessa 2', // <--- ADICIONADO
    rating: 5.0, // <--- ADICIONADO
  ),
  Business(
    id: '3', code: 'spa', name: 'Zen Garden', 
    coverImage: 'https://images.unsplash.com/photo-1600334129128-685c5582fd35?q=80&w=800',
    colorHex: 0xFF00BFFF, type: BusinessType.spa,
    address: 'Cascais, Centro', // <--- ADICIONADO
    rating: 4.8, // <--- ADICIONADO
  ),
];