import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileData {
  final String uid;
  final String nama;
  final String email;
  final String phone;
  final String? photoUrl;
  final String? gender;
  final DateTime? tanggalLahir;

  const UserProfileData({
    required this.uid,
    required this.nama,
    required this.email,
    this.phone = '',
    this.photoUrl,
    this.gender,
    this.tanggalLahir,
  });

  String get shortName {
    if (nama.trim().isEmpty) {
      if (email.contains('@')) {
        final prefix = email.split('@').first;
        return prefix.isNotEmpty
            ? prefix[0].toUpperCase() + prefix.substring(1)
            : 'Pengguna';
      }
      return 'Pengguna';
    }
    return nama.trim().split(' ').first;
  }
}

class UserProfileService extends ChangeNotifier {
  UserProfileService._() {
    _initListener();
  }

  static final UserProfileService instance = UserProfileService._();

  UserProfileData _profile = const UserProfileData(
    uid: '',
    nama: 'Pengguna TEDUH',
    email: '',
  );

  UserProfileData get profile => _profile;
  String get displayName => _profile.nama.isNotEmpty ? _profile.nama : 'Pengguna TEDUH';
  String get shortName => _profile.shortName;
  String get email => _profile.email;
  String get phone => _profile.phone;
  String? get photoUrl => _profile.photoUrl;

  void _initListener() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        loadProfile();
      } else {
        _profile = const UserProfileData(
          uid: '',
          nama: 'Pengguna TEDUH',
          email: '',
        );
        notifyListeners();
      }
    });
  }

  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final cachedName = prefs.getString('user_cached_name');
    final cachedEmail = prefs.getString('user_cached_email') ?? user.email ?? '';
    final cachedPhone = prefs.getString('user_cached_phone') ?? '';
    final cachedPhoto = prefs.getString('user_cached_photo') ?? user.photoURL;

    final initialName = (cachedName != null && cachedName.isNotEmpty)
        ? cachedName
        : (user.displayName != null && user.displayName!.isNotEmpty)
            ? user.displayName!
            : (user.email != null && user.email!.contains('@'))
                ? user.email!.split('@').first
                : 'Pengguna TEDUH';

    _profile = UserProfileData(
      uid: user.uid,
      nama: initialName,
      email: cachedEmail,
      phone: cachedPhone,
      photoUrl: cachedPhoto,
    );
    notifyListeners();

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final firestoreNama = (data['nama'] as String?)?.trim();
        final firestoreEmail = (data['email'] as String?)?.trim() ?? user.email ?? '';
        final firestorePhone = (data['phone'] as String?)?.trim() ?? '';
        final firestorePhoto = (data['photoUrl'] as String?)?.trim() ?? user.photoURL;
        final gender = data['gender'] as String?;
        final tgl = (data['tanggalLahir'] is Timestamp)
            ? (data['tanggalLahir'] as Timestamp).toDate()
            : null;

        final resolvedName = (firestoreNama != null && firestoreNama.isNotEmpty)
            ? firestoreNama
            : (user.displayName != null && user.displayName!.isNotEmpty)
                ? user.displayName!
                : initialName;

        _profile = UserProfileData(
          uid: user.uid,
          nama: resolvedName,
          email: firestoreEmail,
          phone: firestorePhone,
          photoUrl: firestorePhoto,
          gender: gender,
          tanggalLahir: tgl,
        );

        await prefs.setString('user_cached_name', resolvedName);
        await prefs.setString('user_cached_email', firestoreEmail);
        await prefs.setString('user_cached_phone', firestorePhone);
        if (firestorePhoto != null) {
          await prefs.setString('user_cached_photo', firestorePhoto);
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('[UserProfileService] Gagal memuat data Firestore: $e');
    }
  }

  Future<void> updateProfile({
    required String nama,
    required String phone,
    String? email,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      if (user.displayName != nama) {
        await user.updateDisplayName(nama);
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'nama': nama,
        'phone': phone,
        if (email != null && email.isNotEmpty) 'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _profile = UserProfileData(
        uid: user.uid,
        nama: nama,
        email: email ?? _profile.email,
        phone: phone,
        photoUrl: _profile.photoUrl,
        gender: _profile.gender,
        tanggalLahir: _profile.tanggalLahir,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_cached_name', nama);
      await prefs.setString('user_cached_phone', phone);
      if (email != null) await prefs.setString('user_cached_email', email);

      notifyListeners();
    } catch (e) {
      debugPrint('[UserProfileService] Error updateProfile: $e');
      rethrow;
    }
  }

  Future<void> updatePhoto(String? photoPathOrUrl) async {
    final prefs = await SharedPreferences.getInstance();
    if (photoPathOrUrl == null || photoPathOrUrl.isEmpty) {
      await prefs.remove('user_cached_photo');
    } else {
      await prefs.setString('user_cached_photo', photoPathOrUrl);
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'photoUrl': photoPathOrUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (photoPathOrUrl != null &&
            (photoPathOrUrl.startsWith('http://') || photoPathOrUrl.startsWith('https://'))) {
          await user.updatePhotoURL(photoPathOrUrl);
        }
      } catch (e) {
        debugPrint('[UserProfileService] Gagal menyinkronkan foto ke Firestore: $e');
      }
    }

    _profile = UserProfileData(
      uid: _profile.uid,
      nama: _profile.nama,
      email: _profile.email,
      phone: _profile.phone,
      photoUrl: photoPathOrUrl,
      gender: _profile.gender,
      tanggalLahir: _profile.tanggalLahir,
    );

    notifyListeners();
  }

  Future<void> syncGoogleUser(User user) async {
    final prefs = await SharedPreferences.getInstance();

    final emailPrefix = user.email != null && user.email!.contains('@')
        ? user.email!.split('@').first
        : 'Pengguna Google';
    final googleName = (user.displayName != null && user.displayName!.isNotEmpty)
        ? user.displayName!
        : emailPrefix;

    final email = user.email ?? '';
    final photo = user.photoURL;

    String resolvedName = googleName;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        final existingName = (doc.data()!['nama'] as String?)?.trim();
        if (existingName != null && existingName.isNotEmpty) {
          resolvedName = existingName;
        }
      }
    } catch (e) {
      debugPrint('[UserProfileService] syncGoogleUser: gagal cek Firestore: $e');
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'nama': resolvedName,
        'email': email,
        'photoUrl': photo,
        'provider': 'google',
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[UserProfileService] Error syncGoogleUser Firestore: $e');
    }

    _profile = UserProfileData(
      uid: user.uid,
      nama: resolvedName,
      email: email,
      photoUrl: photo,
    );

    await prefs.setString('user_cached_name', resolvedName);
    await prefs.setString('user_cached_email', email);
    if (photo != null) await prefs.setString('user_cached_photo', photo);

    notifyListeners();
  }
}

