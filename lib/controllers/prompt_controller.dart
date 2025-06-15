// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:almari/controllers/swiping_controller.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// // Enum to distinguish between text and image messages
// enum ChatItemType { text, image, promptWithButton }

// // Class to represent chat items (text messages or images)
// class ChatItem {
//   final String content;
//   final bool isSentByUser;
//   final ChatItemType type;
//   final Uint8List? imageData;
//   final String caption;

//   ChatItem({
//     required this.content,
//     required this.isSentByUser,
//     required this.type,
//     this.imageData,
//     this.caption = '',
//   });
// }

// class PromptController extends GetxController {
//   var chatItems = <ChatItem>[].obs;
//   var userInput = ''.obs;
//   var isLoading = false.obs;
//   final SwipingController swipingController = Get.find<SwipingController>();
//   final ScrollController scrollController = ScrollController();

//   @override
//   void onInit() {
//     super.onInit();
//     addBotMessage("How can I assist you today?");
//   }

//   void addUserMessage(String message) {
//     chatItems.add(ChatItem(
//       content: message,
//       isSentByUser: true,
//       type: ChatItemType.text,
//     ));
//     scrollToBottom();
//   }

//   void addBotMessage(String message) {
//     chatItems.add(ChatItem(
//       content: message,
//       isSentByUser: false,
//       type: ChatItemType.text,
//     ));
//     scrollToBottom();
//   }

//   void addBotImageMessage(Uint8List imageData,
//       {String caption = "Here's an outfit suggestion for you:"}) {
//     chatItems.add(ChatItem(
//       content: "",
//       isSentByUser: false,
//       type: ChatItemType.image,
//       imageData: imageData,
//       caption: caption,
//     ));
//     scrollToBottom();
//   }

//   void clearInput() {
//     userInput.value = '';
//   }

//   Future<String> _fetchUserGender() async {
//     String defaultGender = "men";
//     try {
//       String? userId = FirebaseAuth.instance.currentUser?.uid;
//       if (userId == null) return defaultGender;

//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId)
//           .get();

//       if (userDoc.exists) {
//         String gender = userDoc['gender'] ?? '';
//         return (gender.toLowerCase() == 'female') ? 'women' : 'men';
//       }
//     } catch (error) {
//       print("Error fetching gender: $error");
//     }
//     return defaultGender;
//   }

//   Future<void> fetchResponse(String message) async {
//     isLoading.value = true;
//     const apiUrl = "http://192.168.0.103:5000/prompt";

//     List<String> likedImageIds =
//         swipingController.likedImages.map((item) => item.id).toList();

//     try {
//       String genderCategory = await _fetchUserGender();
//       print(jsonEncode({
//         'query': message,
//         'liked_images_id': likedImageIds,
//         'gender': genderCategory,
//       }));

//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'query': message,
//           'liked_images_id': likedImageIds,
//           'gender': genderCategory,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> jsonResp = json.decode(response.body);
//         final String botReply = jsonResp['response'];
//         // addBotMessage(botReply); // Show LLaMA response
//         addGenerateButton(botReply, genderCategory);
//       } else {
//         addBotMessage("Failed to get a response. Please try again later.");
//       }
//     } catch (error) {
//       addBotMessage("Error: $error");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> generateImageFromPrompt(String prompt, String gender) async {
//     const imageApiUrl = "http://192.168.0.103:5000/image";

//     try {
//       final response = await http.post(
//         Uri.parse(imageApiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'prompt': prompt, 'gender': gender}),
//       );

//       if (response.statusCode == 200) {
//         Uint8List imageBytes = response.bodyBytes;
//         addBotImageMessage(imageBytes);
//       } else {
//         addBotMessage("Failed to generate image.");
//       }
//     } catch (error) {
//       addBotMessage("Error generating image: $error");
//     }
//   }

//   // Add the Generate Image button below the prompt
//   void addGenerateButton(String prompt, String gender) {
//     chatItems.add(ChatItem(
//       content: prompt,
//       isSentByUser: false,
//       type: ChatItemType.promptWithButton,
//       caption: gender, // Just store gender directly
//     ));
//     scrollToBottom();
//   }

//   void scrollToBottom() {
//     Future.delayed(Duration(milliseconds: 300), () {
//       if (scrollController.hasClients) {
//         scrollController.animateTo(
//           scrollController.position.maxScrollExtent,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }
// }
import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:almari/controllers/swiping_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ChatItemType { text, image, promptWithButton }

class ChatItem {
  final String content;
  final bool isSentByUser;
  final ChatItemType type;
  final Uint8List? imageData;
  final String caption;

  ChatItem({
    required this.content,
    required this.isSentByUser,
    required this.type,
    this.imageData,
    this.caption = '',
  });
}

class PromptController extends GetxController {
  var chatItems = <ChatItem>[].obs;
  var userInput = ''.obs;
  var isLoading = false.obs;
  final SwipingController swipingController = Get.find<SwipingController>();
  final ScrollController scrollController = ScrollController();

  // Loading overlay variables
  RxBool showLoadingOverlay = false.obs;
  RxDouble overlayOpacity = 0.9.obs;
  final funFacts = [
    "👗 The little pocket in jeans was designed for pocket watches",
    "👠 Red soles became iconic after Christian Louboutin used red nail polish",
    "🧥 Burberry's trench coat design is unchanged since 1912",
    "👖 Levi Strauss originally marketed jeans to gold miners",
  ].obs;
  RxString currentFact = ''.obs;
  Timer? _factTimer;

  @override
  void onInit() {
    super.onInit();
    addBotMessage("How can I assist you today?");
  }

  @override
  void onClose() {
    _factTimer?.cancel();
    super.onClose();
  }

  void clearInput() {
    userInput.value = '';
  }

  void _startFactTimer() {
    showLoadingOverlay.value = true;
    currentFact.value = funFacts[Random().nextInt(funFacts.length)];
    _factTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      currentFact.value = funFacts[Random().nextInt(funFacts.length)];
    });
  }

  void _stopFactTimer() {
    _factTimer?.cancel();
    showLoadingOverlay.value = false;
  }

  void addUserMessage(String message) {
    chatItems.add(ChatItem(
      content: message,
      isSentByUser: true,
      type: ChatItemType.text,
    ));
    scrollToBottom();
  }

  void addBotMessage(String message) {
    chatItems.add(ChatItem(
      content: message,
      isSentByUser: false,
      type: ChatItemType.text,
    ));
    scrollToBottom();
  }

  void addBotImageMessage(Uint8List imageData,
      {String caption = "Here's an outfit suggestion for you:"}) {
    chatItems.add(ChatItem(
      content: "",
      isSentByUser: false,
      type: ChatItemType.image,
      imageData: imageData,
      caption: caption,
    ));
    scrollToBottom();
  }

  void addGenerateButton(String prompt, String gender) {
    chatItems.add(ChatItem(
      content: prompt,
      isSentByUser: false,
      type: ChatItemType.promptWithButton,
      caption: gender,
    ));
    scrollToBottom();
  }

  void scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<String> _fetchUserGender() async {
    String defaultGender = "men";
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return defaultGender;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        String gender = userDoc['gender'] ?? '';
        return (gender.toLowerCase() == 'female') ? 'women' : 'men';
      }
    } catch (error) {
      print("Error fetching gender: $error");
    }
    return defaultGender;
  }

  Future<void> fetchResponse(String message) async {
    isLoading.value = true;
    const apiUrl = "http://192.168.189.203:5000/prompt";

    List<String> likedImageIds =
        swipingController.likedImages.map((item) => item.id).toList();

    try {
      String genderCategory = await _fetchUserGender();
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': message,
          'liked_images_id': likedImageIds,
          'gender': genderCategory,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResp = json.decode(response.body);
        final String botReply = jsonResp['response'];
        addGenerateButton(botReply, genderCategory);
      } else {
        addBotMessage("Failed to get a response. Please try again later.");
      }
    } catch (error) {
      addBotMessage("Error: $error");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generateImageFromPrompt(String prompt, String gender) async {
    isLoading.value = true;
    _startFactTimer();

    const imageApiUrl = "http://192.168.189.203:5000/image";

    try {
      final response = await http.post(
        Uri.parse(imageApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt, 'gender': gender}),
      );

      if (response.statusCode == 200) {
        Uint8List imageBytes = response.bodyBytes;
        addBotImageMessage(imageBytes);
      } else {
        addBotMessage("Failed to generate image.");
      }
    } catch (error) {
      addBotMessage("Error generating image: $error");
    } finally {
      isLoading.value = false;
      _stopFactTimer();
    }
  }
}
