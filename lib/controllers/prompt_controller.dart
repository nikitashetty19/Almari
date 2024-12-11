import 'package:get/get.dart';

class PromptController extends GetxController {
  var messages = <String>[].obs; // Observable list of messages
  var userInput = ''.obs; // Observable for the input text

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
}
