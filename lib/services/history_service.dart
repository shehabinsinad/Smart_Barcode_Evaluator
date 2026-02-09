import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add a scan to Cloud Firestore.
  Future<void> addScan(Map<String, dynamic> scanData) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    
    if (userId == null) {
      throw Exception('User not logged in');
    }
    
    // Add timestamp if not present
    scanData['timestamp'] = scanData['timestamp'] ?? DateTime.now().toIso8601String();
    scanData['userId'] = userId;
    
    await _firestore.collection('scanHistory').add(scanData);
  }

  /// Retrieve scan history from Cloud Firestore for the current user.
  Future<List<Map<String, dynamic>>> getHistory() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    
    if (userId == null) {
      return [];
    }
    
    final querySnapshot = await _firestore
        .collection('scanHistory')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();
    
    return querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }
}
