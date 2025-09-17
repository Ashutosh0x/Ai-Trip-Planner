import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSchemaService {
  FirestoreSchemaService(this._firestore);

  final FirebaseFirestore _firestore;

  // Users
  Future<void> upsertUser({
    required String userId,
    required String name,
    required String email,
    String? photoUrl,
    String? provider,
    Map<String, dynamic>? onboardingPreferences,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'name': name,
      'email': email,
      'profileImageUrl': photoUrl,
      'provider': provider,
      'onboardingPreferences': onboardingPreferences,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Trips
  Future<String> createTrip({
    required String userId,
    required String destination,
    DateTime? startDate,
    DateTime? endDate,
    num? budget,
    String status = 'Planned',
    Map<String, dynamic>? itinerary,
  }) async {
    final doc = _firestore.collection('trips').doc();
    await doc.set({
      'tripId': doc.id,
      'userId': userId,
      'destination': destination,
      'startDate': startDate != null ? Timestamp.fromDate(startDate) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate) : null,
      'budget': budget,
      'status': status,
      'itinerary': itinerary,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // Itinerary Generation (AI + MCP)
  Future<String> createItineraryGeneration({
    required String tripId,
    required String userId,
    Map<String, dynamic>? mcpRequest,
    Map<String, dynamic>? mcpResponse,
    String? modelVersion,
  }) async {
    final doc = _firestore.collection('itinerary_generations').doc();
    await doc.set({
      'itineraryId': doc.id,
      'tripId': tripId,
      'userId': userId,
      'mcpRequest': mcpRequest,
      'mcpResponse': mcpResponse,
      'modelVersion': modelVersion,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // AI Chat / Messages
  Future<String> addMessage({
    required String userId,
    String? tripId,
    required String message,
    required String sender,
    Map<String, dynamic>? contextData,
  }) async {
    final doc = _firestore.collection('messages').doc();
    await doc.set({
      'messageId': doc.id,
      'tripId': tripId,
      'userId': userId,
      'message': message,
      'sender': sender,
      'contextData': contextData,
      'timestamp': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // Google API / ADK Integration
  Future<String> addGoogleApiData({
    required String userId,
    String? tripId,
    List<Map<String, dynamic>>? placesVisited,
    Map<String, dynamic>? mapData,
    Map<String, dynamic>? adkData,
  }) async {
    final doc = _firestore.collection('google_api_data').doc();
    await doc.set({
      'googleApiId': doc.id,
      'userId': userId,
      'tripId': tripId,
      'placesVisited': placesVisited,
      'mapData': mapData,
      'adkData': adkData,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // Bookings / Payments
  Future<String> addBooking({
    required String tripId,
    required String paymentStatus,
    required String paymentMethod,
    required num amount,
    String? transactionId,
  }) async {
    final doc = _firestore.collection('bookings').doc();
    await doc.set({
      'bookingId': doc.id,
      'tripId': tripId,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'amount': amount,
      'transactionId': transactionId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // Notifications
  Future<String> addNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
  }) async {
    final doc = _firestore.collection('notifications').doc();
    await doc.set({
      'notificationId': doc.id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // Budget Tracking
  Future<String> addBudgetItem({
    required String tripId,
    required String userId,
    required num spentAmount,
    required String category,
  }) async {
    final doc = _firestore.collection('budgets').doc();
    await doc.set({
      'budgetId': doc.id,
      'tripId': tripId,
      'userId': userId,
      'spentAmount': spentAmount,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // Activity / Attractions
  Future<String> addActivity({
    required String tripId,
    required String name,
    String? description,
    Map<String, dynamic>? location,
    String? category,
    Timestamp? timeSlot,
  }) async {
    final doc = _firestore.collection('activities').doc();
    await doc.set({
      'activityId': doc.id,
      'tripId': tripId,
      'name': name,
      'description': description,
      'location': location,
      'category': category,
      'timeSlot': timeSlot,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // Reviews / Ratings
  Future<String> addReview({
    required String userId,
    String? tripId,
    String? activityId,
    required num rating,
    String? comment,
  }) async {
    final doc = _firestore.collection('reviews').doc();
    await doc.set({
      'reviewId': doc.id,
      'userId': userId,
      'tripId': tripId,
      'activityId': activityId,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // Search (Google Search Integration)
  Future<String> addSearchQuery({
    required String userId,
    required String queryText,
    required String platform,
    required String method,
    String? cseId,
    Map<String, dynamic>? clickedResult,
  }) async {
    final doc = _firestore.collection('search_queries').doc();
    await doc.set({
      'queryId': doc.id,
      'userId': userId,
      'queryText': queryText,
      'platform': platform,
      'method': method,
      'cseId': cseId,
      'clickedResult': clickedResult,
      'timestamp': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }
}


