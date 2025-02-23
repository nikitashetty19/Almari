import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:almari/controllers/prompt_controller.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});
  final PromptController controller = Get.put(PromptController());
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Almari Stylist',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final isSentByUser = index % 2 != 0;
                    return Align(
                      alignment: isSentByUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSentByUser
                              ? Colors.blue[100]
                              : const Color.fromARGB(255, 231, 225, 225),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isSentByUser
                                ? const Radius.circular(16)
                                : const Radius.circular(0),
                            bottomRight: isSentByUser
                                ? const Radius.circular(0)
                                : const Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          controller.messages[index],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                )),
          ),
          if (controller.isLoading.value)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                // Input Field
                Expanded(
                  child: TextField(
                    controller: textController,
                    onChanged: (value) => controller.userInput.value = value,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Type here...',
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                // Send Button
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final message = controller.userInput.value;
                    if (message.isNotEmpty) {
                      controller.addMessage(message); // Add user message
                      textController.clear();
                      controller.clearInput();
                      controller.addResponse(message); // Send message to API
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
