// import 'package:get/get.dart';
// import '../models/clothing.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// class SwipingController extends GetxController {
//   // final List<Clothing> clothingList = [
//   //   Clothing('assets/image1.jpg'),
//   //   Clothing('assets/image2.jpg'),
//   //   Clothing('assets/IMG_5395.PNG'),
//   //   Clothing('assets/IMG_5396.PNG'),
//   //   Clothing('assets/pic3.png'),
//   //   Clothing('assets/IMG_5410.PNG'),
//   //   Clothing('assets/IMG_5411.PNG'),
//   //   Clothing('assets/IMG_5412.PNG'),
//   //   Clothing('assets/IMG_5413.PNG'),
//   //   Clothing('assets/IMG_5414.PNG'),
//   //   Clothing('assets/IMG_5415.PNG'),
//   //   Clothing('assets/IMG_5416.PNG'),
//   //   Clothing('assets/IMG_5418.PNG'),
//   //   Clothing('assets/IMG_5419.PNG'),
//   //   Clothing('assets/IMG_5420.PNG'),
//   //   Clothing('assets/IMG_5421.PNG'),
//   //   Clothing('assets/IMG_5422.PNG'),
//   //   Clothing('assets/IMG_5423.PNG'),
//   //   Clothing('assets/IMG_5424.PNG'),
//   //   Clothing('assets/IMG_5425.PNG'),
//   //   Clothing('assets/IMG_5426.PNG'),
//   //   Clothing('assets/IMG_5427.PNG'),
//   //   Clothing('assets/IMG_5428.PNG'),
//   //   Clothing('assets/IMG_5429.PNG'),
//   //   Clothing('assets/IMG_5430.PNG'),
//   //   Clothing('assets/IMG_5431.PNG'),
//   //   Clothing('assets/IMG_5432.PNG'),
//   //   Clothing('assets/IMG_5433.PNG'),
//   //   Clothing('assets/IMG_5434.PNG'),
//   //   Clothing('assets/IMG_5435.PNG'),
//   //   Clothing('assets/IMG_5436.PNG'),
//   //   Clothing('assets/IMG_5437.PNG'),
//   //   Clothing('assets/IMG_5438.PNG'),
//   //   Clothing('assets/IMG_5439.PNG'),
//   //   Clothing('assets/IMG_5440.PNG'),
//   //   Clothing('assets/IMG_5441.PNG'),
//   //   Clothing('assets/IMG_5442.PNG'),
//   //   Clothing('assets/IMG_5443.PNG'),
//   //   Clothing('assets/IMG_5444.PNG'),
//   //   Clothing('assets/IMG_5445.PNG'),
//   //   Clothing('assets/IMG_5446.PNG'),
//   //   Clothing('assets/IMG_5447.PNG'),
//   //   Clothing('assets/IMG_5448.PNG'),
//   //   Clothing('assets/IMG_5449.PNG'),
//   //   Clothing('assets/IMG_5450.PNG'),
//   //   Clothing('assets/IMG_5451.PNG'),
//   //   Clothing('assets/IMG_5452.PNG'),
//   //   Clothing('assets/IMG_5453.PNG'),
//   //   Clothing('assets/pic1.png'),
//   //   Clothing('assets/pic2.png'),
//   // ];

//   var clothingList = <Clothing>[].obs;
//   var likedImages = <Clothing>[].obs;
//   var dislikedImages = <Clothing>[].obs;

//   var showHeart = false.obs;
//   var showCancel = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     loadClothingImages(); // Load images from Firebase Storage
//   }

//   Future<void> loadClothingImages() async {
//     final storageRef = FirebaseStorage.instance.ref();
//     final menFolderRef = storageRef.child('Women');
//     try {
//       final ListResult result = await menFolderRef.listAll();
//       final List<Reference> allFiles = result.items;

//       // Iterate over the files and fetch download URLs
//       for (var file in allFiles) {
//         final String url = await file.getDownloadURL();
//         clothingList.add(Clothing(url)); // Add the URL to clothing list
//       }
//     } catch (e) {
//       print("Error loading images from Firebase Storage: $e");
//     }
//   }

//   // Method to handle a swipe action
//   void handleSwipe(int index, bool isLiked) {
//     if (index >= clothingList.length) return; // Boundary check

//     if (isLiked) {
//       likeImage(index); // Add to liked list
//       showHeartEffect(); // Trigger heart effect
//     } else {
//       dislikeImage(index);
//       showCancelEffect(); // Add to disliked list
//     }
//   }

//   // Add to liked images
//   void likeImage(int index) {
//     if (!likedImages.contains(clothingList[index])) {
//       likedImages.add(clothingList[index]);
//     }
//   }

//   void dislikeImage(int index) {
//     if (!dislikedImages.contains(clothingList[index])) {
//       dislikedImages.add(clothingList[index]);
//     }
//   }

//   // Show heart effect for a short duration
//   void showHeartEffect() {
//     showHeart.value = true;
//     Future.delayed(const Duration(milliseconds: 500), () {
//       showHeart.value = false; // Reset after 300ms
//     });
//   }

//   void showCancelEffect() {
//     showCancel.value = true;
//     Future.delayed(const Duration(milliseconds: 500), () {
//       showCancel.value = false;
//     });
//   }
// }

import 'package:get/get.dart';
import '../models/clothing.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SwipingController extends GetxController {
  var clothingList = <Clothing>[].obs;
  var likedImages = <Clothing>[].obs;
  var dislikedImages = <Clothing>[].obs;

  var showHeart = false.obs;
  var showCancel = false.obs;

  var isLoadingMore = false.obs; // Indicates if more images are being loaded
  String? nextPageToken; // Token for next page of Firebase Storage

  @override
  void onInit() {
    super.onInit();
    loadClothingImages(); // Load images from Firebase Storage
  }

  Future<void> loadClothingImages() async {
    if (isLoadingMore.value) return; // Prevent concurrent loading
    isLoadingMore.value = true;

    final storageRef = FirebaseStorage.instance.ref();
    final womenFolderRef = storageRef.child('Women');
    try {
      final ListResult result = await womenFolderRef.list(ListOptions(
        maxResults: 10, // Number of items to fetch per batch
        pageToken: nextPageToken,
      ));
      nextPageToken = result.nextPageToken; // Save the next page token

      // Iterate over the files and fetch download URLs
      for (var file in result.items) {
        final String url = await file.getDownloadURL();
        clothingList.add(Clothing(url)); // Add the URL to clothing list
      }
    } catch (e) {
      print("Error loading images from Firebase Storage: $e");
    } finally {
      isLoadingMore.value = false;
    }
  }

  // Method to load more images (triggered on reaching the end)
  Future<void> loadMoreImages() async {
    if (nextPageToken != null) {
      await loadClothingImages();
    }
  }

  // Method to handle a swipe action
  void handleSwipe(int index, bool isLiked) {
    if (index >= clothingList.length) return; // Boundary check

    if (isLiked) {
      likeImage(index); // Add to liked list
      showHeartEffect(); // Trigger heart effect
    } else {
      dislikeImage(index);
      showCancelEffect(); // Add to disliked list
    }

    // Load more images if nearing the end of the list
    if (index >= clothingList.length - 3) {
      loadMoreImages();
    }
  }

  // Add to liked images
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

  // Show heart effect for a short duration
  void showHeartEffect() {
    showHeart.value = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      showHeart.value = false; // Reset after 300ms
    });
  }

  void showCancelEffect() {
    showCancel.value = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      showCancel.value = false;
    });
  }
}
