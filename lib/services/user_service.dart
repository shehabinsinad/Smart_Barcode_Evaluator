import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save user data to Cloud Firestore.
  Future<void> saveUserData(String name, String height, String weight, String allergies, String conditions) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    
    if (userId == null) {
      throw Exception('User not logged in');
    }
    
    await _firestore.collection('users').doc(userId).set({
      'name': name,
      'height': height,
      'weight': weight,
      'allergies': allergies,
      'conditions': conditions,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Retrieve user data from Cloud Firestore.
  Future<Map<String, String>> getUserData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    
    if (userId == null) {
      return {
        'name': '',
        'height': '',
        'weight': '',
        'allergies': '',
        'conditions': '',
      };
    }
    
    final doc = await _firestore.collection('users').doc(userId).get();
    
    if (!doc.exists) {
      return {
        'name': '',
        'height': '',
        'weight': '',
        'allergies': '',
        'conditions': '',
      };
    }
    
    final data = doc.data()!;
    return {
      'name': data['name']?.toString() ?? '',
      'height': data['height']?.toString() ?? '',
      'weight': data['weight']?.toString() ?? '',
      'allergies': data['allergies']?.toString() ?? '',
      'conditions': data['conditions']?.toString() ?? '',
    };
  }
}
