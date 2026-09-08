import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class EventifyService {
  static FirebaseApp? _eventifyApp;
  static FirebaseFirestore? _eventifyFirestore;

  /// Inicializa a ligação direta ao projeto eventify-6da31
  static Future<FirebaseFirestore> _getFirestore() async {
    if (_eventifyFirestore != null) return _eventifyFirestore!;

    try {
      // Tenta obter a instância se já existir
      _eventifyApp = Firebase.app('EventifyApp');
    } catch (_) {
      // Se não existir, inicializa uma ligação isolada ao Eventify
      _eventifyApp = await Firebase.initializeApp(
        name: 'EventifyApp',
        options: const FirebaseOptions(
          apiKey: "AIzaSyDummyKeyEventifyApp", // O Firestore com leitura pública não valida a apiKey
          appId: "1:309247261526:android:ad40935656a19c73ba34f7",
          messagingSenderId: "309247261526",
          projectId: "eventify-6da31", // O ID REAL DO TEU EVENTIFY
        ),
      );
    }

    _eventifyFirestore = FirebaseFirestore.instanceFor(app: _eventifyApp!);
    return _eventifyFirestore!;
  }

  static Future<List<Map<String, dynamic>>> getEvents() async {
    try {
      debugPrint('🔥 [EventifyService] A ligar ao projeto eventify-6da31...');

      final firestore = await _getFirestore();
      final snapshot = await firestore.collection('events').get();

      debugPrint('🔥 [EventifyService] Documentos recebidos do Eventify: ${snapshot.docs.length}');

      final List<Map<String, dynamic>> list = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        debugPrint('🔥 [Doc ID ${doc.id}] Dados: $data');

        if (data.isEmpty || data['title'] == null) continue;

        String formattedDate = data['dateTime']?.toString() ?? 'Brevemente';
        if (formattedDate.contains('T')) {
          final parts = formattedDate.split('T');
          final datePart = parts[0];
          final timePart = parts[1].length >= 5 ? parts[1].substring(0, 5) : parts[1];
          formattedDate = '$datePart às $timePart';
        }

        list.add({
          'id': doc.id,
          'title': data['title'] ?? 'Evento',
          'category': data['category'] ?? 'EVENTO',
          'date': formattedDate,
          'location': data['locationName'] ?? 'Portugal',
          'banner_url': data['imageUrl'] ?? 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=800&q=80',
          'description': (data['description'] != null && data['description'].toString().trim().isNotEmpty)
              ? data['description']
              : 'Junta-te a este evento oficial do Eventify e usufrui de vantagens exclusivas.',
          'price': data['price']?.toString() ?? '0',
          'ticket_url': 'https://eventify.pt',
          'download_url': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        });
      }

      debugPrint('🔥 [EventifyService] Total processado com sucesso: ${list.length}');
      return list;
    } catch (e, stack) {
      debugPrint('🚨 [EventifyService] ERRO AO LER FIRESTORE DO EVENTIFY: $e');
      debugPrint('🚨 [EventifyService] Stack: $stack');
      return [];
    }
  }
}