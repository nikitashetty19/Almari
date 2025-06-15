// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:almari/controllers/prompt_controller.dart';

// class SearchScreen extends StatelessWidget {
//   SearchScreen({super.key});
//   final PromptController controller = Get.put(PromptController());
//   final TextEditingController textController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Almari Stylist',
//           style: TextStyle(fontFamily: 'Poppins'),
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Obx(() => ListView.builder(
//                   controller: controller.scrollController,
//                   itemCount: controller.chatItems.length,
//                   itemBuilder: (context, index) {
//                     final item = controller.chatItems[index];
//                     final isSentByUser = item.isSentByUser;

//                     // 🧠 PROMPT + GENERATE BUTTON (New type)
//                     if (item.type == ChatItemType.promptWithButton) {
//                       final gender = item.caption.split(":").last;
//                       return Align(
//                         alignment: Alignment.centerLeft,
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(
//                               vertical: 4.0, horizontal: 8.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Show prompt in a chat bubble
//                               Container(
//                                 padding: const EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color:
//                                       const Color.fromARGB(255, 231, 225, 225),
//                                   borderRadius: const BorderRadius.only(
//                                     topLeft: Radius.circular(16),
//                                     topRight: Radius.circular(16),
//                                     bottomRight: Radius.circular(16),
//                                   ),
//                                 ),
//                                 child: Text(
//                                   item.content,
//                                   style: const TextStyle(
//                                       fontSize: 16, color: Colors.black),
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               ElevatedButton.icon(
//                                 onPressed: () {
//                                   controller.generateImageFromPrompt(
//                                       item.content, gender);
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 12, vertical: 8),
//                                   minimumSize: Size(100, 30),
//                                   backgroundColor: Colors.grey[300],
//                                   foregroundColor: Colors.black87,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                 ),
//                                 icon: const Icon(Icons.auto_awesome),
//                                 label: const Text("Generate Image"),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }

//                     // 💬 Text Message
//                     if (item.type == ChatItemType.text) {
//                       return Align(
//                         alignment: isSentByUser
//                             ? Alignment.centerRight
//                             : Alignment.centerLeft,
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(
//                               vertical: 4.0, horizontal: 8.0),
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: isSentByUser
//                                 ? Colors.blue[100]
//                                 : const Color.fromARGB(255, 231, 225, 225),
//                             borderRadius: BorderRadius.only(
//                               topLeft: const Radius.circular(16),
//                               topRight: const Radius.circular(16),
//                               bottomLeft: isSentByUser
//                                   ? const Radius.circular(16)
//                                   : const Radius.circular(0),
//                               bottomRight: isSentByUser
//                                   ? const Radius.circular(0)
//                                   : const Radius.circular(16),
//                             ),
//                           ),
//                           child: Text(
//                             item.content,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               color: Colors.black,
//                             ),
//                           ),
//                         ),
//                       );
//                     }

//                     // 🖼️ Image Message
//                     if (item.type == ChatItemType.image) {
//                       return Align(
//                         alignment: Alignment.centerLeft,
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(
//                               vertical: 4.0, horizontal: 8.0),
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: const Color.fromARGB(255, 231, 225, 225),
//                             borderRadius: const BorderRadius.only(
//                               topLeft: Radius.circular(16),
//                               topRight: Radius.circular(16),
//                               bottomLeft: Radius.circular(0),
//                               bottomRight: Radius.circular(16),
//                             ),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               if (item.caption.isNotEmpty)
//                                 Padding(
//                                   padding: const EdgeInsets.only(bottom: 8.0),
//                                   child: Text(
//                                     item.caption,
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                 ),
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(12),
//                                 child: Container(
//                                   constraints: BoxConstraints(
//                                     maxWidth:
//                                         MediaQuery.of(context).size.width * 0.6,
//                                     maxHeight: 250,
//                                   ),
//                                   child: Image.memory(
//                                     item.imageData!,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }

//                     return const SizedBox.shrink();
//                   },
//                 )),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: textController,
//                     onChanged: (value) => controller.userInput.value = value,
//                     decoration: InputDecoration(
//                       filled: true,
//                       hintText: 'Type here...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: () {
//                     final message = controller.userInput.value;
//                     if (message.isNotEmpty) {
//                       controller.addUserMessage(message);
//                       textController.clear();
//                       controller.clearInput();
//                       controller.fetchResponse(message);
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
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
          style: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
      body: Stack(
        children: [
          // Original chat UI
          Column(
            children: [
              Expanded(
                child: Obx(() => ListView.builder(
                      controller: controller.scrollController,
                      itemCount: controller.chatItems.length,
                      itemBuilder: (context, index) {
                        final item = controller.chatItems[index];
                        final isSentByUser = item.isSentByUser;

                        if (item.type == ChatItemType.promptWithButton) {
                          final gender = item.caption.split(":").last;
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 231, 225, 225),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: Text(
                                      item.content,
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      controller.generateImageFromPrompt(
                                          item.content, gender);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      minimumSize: Size(100, 30),
                                      backgroundColor: Colors.grey[300],
                                      foregroundColor: Colors.black87,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon: const Icon(Icons.auto_awesome),
                                    label: const Text("Generate Image"),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (item.type == ChatItemType.text) {
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
                                item.content,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          );
                        }

                        if (item.type == ChatItemType.image) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 231, 225, 225),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                  bottomLeft: Radius.circular(0),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item.caption.isNotEmpty)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        item.caption,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        maxHeight: 250,
                                      ),
                                      child: Image.memory(
                                        item.imageData!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        onChanged: (value) =>
                            controller.userInput.value = value,
                        decoration: InputDecoration(
                          filled: true,
                          hintText: 'Type here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        final message = controller.userInput.value;
                        if (message.isNotEmpty) {
                          controller.addUserMessage(message);
                          textController.clear();
                          controller.clearInput();
                          controller.fetchResponse(message);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Loading overlay (fully opaque black)
          Obx(
            () => controller.showLoadingOverlay.value
                ? Opacity(
                    opacity: controller.overlayOpacity.value,
                    child: Container(
                      color: Colors.black.withOpacity(0.85),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 20),
                            Obx(() => Text(
                                  controller.currentFact.value,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center,
                                )),
                          ],
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
