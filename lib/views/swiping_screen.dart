import 'package:almari/views/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import 'package:palette_generator/palette_generator.dart'; // For extracting colors
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/swiping_controller.dart'; // Import your controller
import '../models/clothing.dart'; // Import your model
import 'search_screen.dart';

class SwipingScreen extends StatefulWidget {
  const SwipingScreen({super.key});

  @override
  _SwipingScreenState createState() => _SwipingScreenState();
}

class _SwipingScreenState extends State<SwipingScreen> {
  final SwipingController controller = Get.find(); // Get the controller
  final CardSwiperController swiperController = CardSwiperController();

  final Rx<Color> dominantColor = Colors.black.obs; // Default background color

  @override
  void initState() {
    super.initState();
    if (controller.clothingList.isNotEmpty) {
      _updateDominantColor(controller.clothingList.first.imagePath);
    }
  }

  @override
  void dispose() {
    swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // **Gradient Background that updates dynamically**
          Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      dominantColor.value.withOpacity(0.8),
                      Colors.black.withOpacity(0.9),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              )),

          SafeArea(
            child: Column(
              children: [
                // **App Bar**
                AppBar(
                  title: const Text(
                    'ALMARI',
                    style: TextStyle(
                      // fontStyle: FontStyle.italic,
                      fontSize: 30,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        Get.to(() => SearchScreen());
                      },
                      icon: const Icon(Icons.search),
                    ),
                    IconButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Get.offAll(() => LoginPage());
                      },
                      icon: const Icon(Icons.logout),
                    ),
                  ],
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),

                // **Swiping Cards**
                Expanded(
                  child: Obx(() {
                    if (controller.clothingList.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return CardSwiper(
                      controller: swiperController,
                      cardsCount: controller.clothingList.length,
                      onSwipe: _onSwipe,
                      cardBuilder: (context, index, _, __) =>
                          _buildClothingCard(controller.clothingList[index]),
                      allowedSwipeDirection: const AllowedSwipeDirection.only(
                          right: true, left: true),
                    );
                  }),
                ),
              ],
            ),
          ),

          // **Overlay for heart or cancel animation**
          Obx(() {
            if (controller.showHeart.value) {
              return Center(
                child: Icon(
                  Icons.favorite,
                  size: 100,
                  color: Colors.red.withOpacity(1),
                ),
              );
            } else if (controller.showCancel.value) {
              return Center(
                child: Icon(
                  Icons.cancel,
                  size: 100,
                  color:
                      const Color.fromARGB(255, 241, 238, 237).withOpacity(1),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }

  // **Function to build a clothing card**
  Widget _buildClothingCard(Clothing clothing) {
    return GestureDetector(
      onTap: () =>
          _updateDominantColor(clothing.imagePath), // Update background color
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: CachedNetworkImageProvider(clothing.imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  // **Callback for when a card is swiped**
  bool _onSwipe(
      int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (direction == CardSwiperDirection.right) {
      controller.handleSwipe(previousIndex, true);
    } else if (direction == CardSwiperDirection.left) {
      controller.handleSwipe(previousIndex, false);
    } else {
      return false;
    }

    // **Update background color**
    if (currentIndex != null && currentIndex < controller.clothingList.length) {
      _updateDominantColor(controller.clothingList[currentIndex].imagePath);
    }

    return true;
  }

  // **Extract dominant color from the image**
  Future<void> _updateDominantColor(String imageUrl) async {
    try {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(imageUrl),
      );

      // Get dominant color (or fallback to default)
      Color newColor = paletteGenerator.dominantColor?.color ?? Colors.grey;
      dominantColor.value = newColor; // Update observable
    } catch (e) {
      print("Error extracting color: $e");
    }
  }
}
