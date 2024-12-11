import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
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

  @override
  void dispose() {
    swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ALMARI',
          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 30),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => SearchScreen());
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: CardSwiper(
                    controller: swiperController,
                    cardsCount: controller.clothingList.length,
                    onSwipe: _onSwipe,
                    onUndo: _onUndo,
                    numberOfCardsDisplayed: 1,
                    maxAngle: 90,
                    threshold: 90,
                    duration: const Duration(milliseconds: 100),
                    backCardOffset: const Offset(40, 40),
                    padding: const EdgeInsets.all(24.0),
                    cardBuilder: (context, index, horizontalThresholdPercentage,
                            verticalThresholdPercentage) =>
                        _buildClothingCard(
                            controller.clothingList[index], index),
                    allowedSwipeDirection: const AllowedSwipeDirection.only(
                        right: true, left: true),
                  ),
                ),
              ],
            ),
            // Overlay for heart or cancel animation
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
      ),
    );
  }

  // Function to build a clothing card
  Widget _buildClothingCard(Clothing clothing, int index) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Image.asset(clothing.imagePath, fit: BoxFit.cover),
    );
  }

  // Callback for when a card is swiped
  bool _onSwipe(
      int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (direction == CardSwiperDirection.right) {
      controller.handleSwipe(previousIndex, true); // Trigger like action
    } else if (direction == CardSwiperDirection.left) {
      controller.handleSwipe(previousIndex, false); // Trigger dislike action
    } else {
      return false;
    }
    return true;
  }

  // Callback for undoing the swipe
  bool _onUndo(
      int? previousIndex, int currentIndex, CardSwiperDirection direction) {
    return true; // You can handle undo if necessary
  }
}
