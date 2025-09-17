import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileService {
  Stream<Map<String, dynamic>?> streamProfile() {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((d) => d.data());
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      ...updates,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> uploadAvatar(File file, {String contentType = 'image/jpeg'}) async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final Reference ref = FirebaseStorage.instance.ref('user_avatars/$uid.jpg');
    await ref.putFile(file, SettableMetadata(contentType: contentType));
    final String url = await ref.getDownloadURL();
    await updateProfile({'photoUrl': url});
    return url;
  }
}


