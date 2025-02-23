import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:almari/controllers/swiping_controller.dart';

class PromptController extends GetxController {
  var messages = <String>[].obs; // Observable list of messages
  var userInput = ''.obs; // Observable for the input text
  var isLoading = false.obs; // Observable for showing loading state
  final SwipingController swipingController = Get.find<SwipingController>();
  @override
  void onInit() {
    super.onInit();
    addMessage("How can I assist you today?"); // Add the initial message
  }

  // Add a message to the list
  void addMessage(String message) {
    messages.add(message);
  }

  // Clear the input field after sending a message
  void clearInput() {
    userInput.value = '';
  }

  Future<void> addResponse(String message) async {
    isLoading.value = true;
    const apiUrl = "http://192.168.152.79:5000/query";

    // Get all liked image IDs (both previous & current session)
    List<String> likedImageIds =
        swipingController.likedImages.map((item) => item.id).toList();

    print("All Liked Image IDs: $likedImageIds");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': message, 'liked_images': likedImageIds}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String reply = data['response'];
        addMessage(reply);
      } else {
        addMessage("Failed to get a response. Please try again later.");
        print("API Error: ${response.body}");
      }
    } catch (error) {
      addMessage("Error: $error");
    } finally {
      isLoading.value = false;
    }
  }
}
