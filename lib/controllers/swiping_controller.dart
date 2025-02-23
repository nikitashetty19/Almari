// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:csv/csv.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import '../models/clothing.dart';

// class SwipingController extends GetxController {
//   // Observable lists
//   var clothingList = <Clothing>[].obs;
//   var likedImages = <Clothing>[].obs;
//   var dislikedImages = <Clothing>[].obs;

//   // UI state
//   var showHeart = false.obs;
//   var showCancel = false.obs;
//   var isLoadingMore = false.obs;

//   // Firebase instances
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   String? nextPageToken;
//   Map<String, String> imageUrlToId = {};

//   // Get current user ID
//   String? get currentUserId => _auth.currentUser?.uid;
//   var userGender = ''.obs;

//   Future<void> loadImageMappings() async {
//     try {
//       print('Attempting to load CSV file for gender: ${userGender.value}');

//       //men
//       // final String csvData =
//       //     await rootBundle.loadString('assets/men_firebase.csv');
//       //women
//       final String csvData =
//           await rootBundle.loadString(userGender.value == 'Male'
//               ? 'assets/men_firebase.csv' // Men see women's clothes
//               : 'assets/women_firebase.csv');
//       print('Successfully read CSV data');

//       final List<List<dynamic>> rowsAsListOfValues =
//           const CsvToListConverter().convert(csvData);

//       if (rowsAsListOfValues.isEmpty) {
//         print('CSV file is empty');
//         return;
//       }

//       print('CSV Header: ${rowsAsListOfValues[0]}');
//       imageUrlToId.clear();
//       // Skip header row (id,url)
//       for (var row in rowsAsListOfValues.skip(1)) {
//         if (row.length >= 2) {
//           String id = row[0].toString().trim();
//           String url = row[1].toString().trim();
//           String folderPath = userGender.value == 'Male' ? '/Men/' : '/Women/';
//           //men
//           // if (url.contains('/Men/')) {
//           //   String fileName = url.split('/Men/')[1].split('?')[0];
//           //   print('Extracted fileName: $fileName for ID: $id');
//           //   imageUrlToId[fileName] = id;
//           // }
//           //women
//           if (url.contains(folderPath)) {
//             String fileName = url.split(folderPath)[1].split('?')[0];
//             print('Extracted fileName: $fileName for ID: $id');
//             imageUrlToId[fileName] = id;
//           }
//         }
//       }

//       print('Loaded ${imageUrlToId.length} image mappings');
//     } catch (e, stackTrace) {
//       print('Error in loadImageMappings: $e');
//       print('Stack trace: $stackTrace');
//     }
//   }

//   Future<void> loadClothingImages() async {
//     if (isLoadingMore.value) return;
//     isLoadingMore.value = true;

//     try {
//       final storageRef = _storage.ref();
//       // final menFolderRef = storageRef.child('Men');
//       final folderRef =
//           storageRef.child(userGender.value == 'Male' ? 'Men' : 'Women');

//       print('Loading images from Firebase Storage...');

//       //men
//       // final ListResult result = await menFolderRef.list(ListOptions(
//       //   maxResults: 10,
//       //   pageToken: nextPageToken,
//       // ));

//       //women
//       final ListResult result = await folderRef.list(ListOptions(
//         maxResults: 10,
//         pageToken: nextPageToken,
//       ));

//       nextPageToken = result.nextPageToken;

//       for (var file in result.items) {
//         try {
//           final String url = await file.getDownloadURL();
//           print('Processing file: ${file.name}');

//           String id = imageUrlToId[file.name] ?? 'unknown';
//           print('File: ${file.name}, Mapped ID: $id');

//           clothingList.add(Clothing(imagePath: url, id: id));
//         } catch (e) {
//           print('Error processing file ${file.name}: $e');
//         }
//       }
//     } catch (e) {
//       print("Error loading images from Firebase Storage: $e");
//     } finally {
//       isLoadingMore.value = false;
//     }
//   }

//   Future<void> fetchUserGender() async {
//     try {
//       if (currentUserId == null) {
//         print('No user logged in');
//         return;
//       }

//       DocumentSnapshot userDoc =
//           await _firestore.collection('users').doc(currentUserId).get();

//       if (userDoc.exists) {
//         Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
//         userGender.value = (userData['gender'] as String);
//         print('Fetched user gender: ${userGender.value}');
//       }
//     } catch (e) {
//       print('Error fetching user gender: $e');
//     }
//   }

//   // Handle swipe actions
//   void handleSwipe(int index, bool isLiked) {
//     if (index >= clothingList.length) return;
//     if (currentUserId == null) {
//       print('Error: No user is currently logged in');
//       return;
//     }

//     final clothing = clothingList[index];
//     print('Processing swipe for image: ${clothing.id}');

//     if (isLiked) {
//       likeImage(index);
//       showHeartEffect();
//       updateLikedImagesInFirestore(clothing.id);
//     } else {
//       dislikeImage(index);
//       showCancelEffect();
//     }

//     if (index >= clothingList.length - 3) {
//       loadMoreImages();
//     }
//   }

//   Future<void> updateLikedImagesInFirestore(String imageId) async {
//     if (currentUserId == null) {
//       print('Error: No user is currently logged in');
//       return;
//     }

//     try {
//       print('Updating Firestore for image ID: $imageId');
//       await _firestore.collection('liked_images').doc(currentUserId).set({
//         'likedImageIds': FieldValue.arrayUnion([imageId])
//       }, SetOptions(merge: true));
//       print('Successfully updated Firestore for image ID: $imageId');
//     } catch (e) {
//       print('Error updating Firestore: $e');
//     }
//   }

//   void likeImage(int index) {
//     if (!likedImages.contains(clothingList[index])) {
//       likedImages.add(clothingList[index]);
//       print('Added image ${clothingList[index].id} to liked list');
//     }
//   }

//   void dislikeImage(int index) {
//     if (!dislikedImages.contains(clothingList[index])) {
//       dislikedImages.add(clothingList[index]);
//     }
//   }

//   void showHeartEffect() {
//     showHeart.value = true;
//     Future.delayed(const Duration(milliseconds: 500), () {
//       showHeart.value = false;
//     });
//   }

//   void showCancelEffect() {
//     showCancel.value = true;
//     Future.delayed(const Duration(milliseconds: 500), () {
//       showCancel.value = false;
//     });
//   }

//   Future<void> loadMoreImages() async {
//     if (nextPageToken != null) {
//       await loadClothingImages();
//     }
//   }

//   @override
//   void onInit() {
//     print("SwipingController initialized");
//     super.onInit();
//     fetchUserGender().then((_) {
//       loadImageMappings().then((_) => loadClothingImages());
//     });
//   }
// }

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/clothing.dart';
import 'dart:math';

class SwipingController extends GetxController {
  // Observable lists
  var clothingList = <Clothing>[].obs;
  var likedImages = <Clothing>[].obs;
  var dislikedImages = <Clothing>[].obs;

  // UI state
  var showHeart = false.obs;
  var showCancel = false.obs;
  var isLoadingMore = false.obs;

  // User state
  var userGender = ''.obs;

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? nextPageToken;
  Map<String, String> imageUrlToId = {};

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        resetController();
      } else {
        loadUserGenderAndData();
        loadLikedImagesFromFirestore();
      }
    });
  }

  void resetController() {
    clothingList.clear();
    likedImages.clear();
    dislikedImages.clear();
    imageUrlToId.clear();
    nextPageToken = null;
  }

  Future<void> loadUserGenderAndData() async {
    if (currentUserId == null) return;

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUserId).get();

      if (userDoc.exists) {
        userGender.value = userDoc.get('gender') as String;
        print('Loaded user gender: ${userGender.value}');
        await loadImageMappings();
        await loadClothingImages();
      }
    } catch (e) {
      print('Error loading user gender: $e');
    }
  }

  Future<void> loadLikedImagesFromFirestore() async {
    if (currentUserId == null) return;

    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('liked_images').doc(currentUserId).get();

      if (snapshot.exists) {
        List<dynamic> likedImageIds = snapshot.get('likedImageIds') ?? [];

        // Convert IDs to Clothing objects (if necessary)
        likedImages
            .addAll(likedImageIds.map((id) => Clothing(id: id, imagePath: '')));
      }
    } catch (e) {
      print('Error loading liked images from Firestore: $e');
    }
  }

  Future<void> loadImageMappings() async {
    try {
      print('Loading CSV for gender: ${userGender.value}');

      // Clear previous mappings
      imageUrlToId.clear();

      // Choose CSV file based on user gender - same gender CSV
      String csvPath = userGender.value == 'Male'
          ? 'assets/men_firebase.csv'
          : 'assets/women_firebase.csv';

      final String csvData = await rootBundle.loadString(csvPath);
      print('Successfully read CSV data from $csvPath');

      final List<List<dynamic>> rowsAsListOfValues =
          const CsvToListConverter().convert(csvData);

      if (rowsAsListOfValues.isEmpty) {
        print('CSV file is empty');
        return;
      }

      // Skip header row
      for (var row in rowsAsListOfValues.skip(1)) {
        if (row.length >= 2) {
          String id = row[0].toString().trim();
          String url = row[1].toString().trim();

          // Use same gender folder name
          String folderName = userGender.value == 'Male' ? 'Men' : 'Women';
          if (url.contains('/$folderName/')) {
            String fileName = url.split('/$folderName/')[1].split('?')[0];
            print('Mapping fileName: $fileName to ID: $id');
            imageUrlToId[fileName] = id;
          }
        }
      }

      print('Loaded ${imageUrlToId.length} image mappings');
    } catch (e, stackTrace) {
      print('Error in loadImageMappings: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> loadClothingImages() async {
    if (isLoadingMore.value) return;
    isLoadingMore.value = true;

    try {
      final storageRef = _storage.ref();
      // Use same gender folder for recommendations
      final folderRef =
          storageRef.child(userGender.value == 'Male' ? 'Men' : 'Women');

      print(
          'Loading images from Firebase Storage folder: ${folderRef.fullPath}');
      final ListResult result = await folderRef.list(ListOptions(
        maxResults: 20,
        pageToken: nextPageToken,
      ));

      nextPageToken = result.nextPageToken;
      List<Clothing> tempClothingList = [];

      for (var file in result.items) {
        try {
          final String url = await file.getDownloadURL();
          String id = imageUrlToId[file.name] ?? 'unknown';
          print('Adding image with fileName: ${file.name}, ID: $id');
          tempClothingList.add(Clothing(imagePath: url, id: id));
        } catch (e) {
          print('Error processing file ${file.name}: $e');
        }
      }
      tempClothingList.shuffle(Random());
      clothingList.addAll(tempClothingList);
    } catch (e) {
      print("Error loading images from Firebase Storage: $e");
    } finally {
      isLoadingMore.value = false;
    }
  }

  // Rest of the controller methods remain the same
  void handleSwipe(int index, bool isLiked) {
    if (index >= clothingList.length) return;
    if (currentUserId == null) {
      print('Error: No user is currently logged in');
      return;
    }

    final clothing = clothingList[index];
    print('Processing swipe for image: ${clothing.id}');

    if (isLiked) {
      likeImage(index);
      showHeartEffect();
      updateLikedImagesInFirestore(clothing.id);
    } else {
      dislikeImage(index);
      showCancelEffect();
    }

    if (index >= clothingList.length - 3) {
      loadMoreImages();
    }
  }

  Future<void> updateLikedImagesInFirestore(String imageId) async {
    if (currentUserId == null) return;

    try {
      await _firestore.collection('liked_images').doc(currentUserId).set({
        'likedImageIds': FieldValue.arrayUnion([imageId])
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }

  void likeImage(int index) {
    if (!likedImages.contains(clothingList[index])) {
      likedImages.add(clothingList[index]);
    }
  }

  void dislikeImage(int index) {
    if (!dislikedImages.contains(clothingList[index])) {
      dislikedImages.add(clothingList[index]);
    }
  }

  void showHeartEffect() {
    showHeart.value = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      showHeart.value = false;
    });
  }

  void showCancelEffect() {
    showCancel.value = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      showCancel.value = false;
    });
  }

  Future<void> loadMoreImages() async {
    if (nextPageToken != null) {
      await loadClothingImages();
    }
  }
}
