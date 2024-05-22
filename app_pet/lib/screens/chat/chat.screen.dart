import 'package:flutter/material.dart';
import 'package:ikchatbot/ikchatbot.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/screens/chat/keyword_response.chat.dart';

class ChatScreen extends StatefulWidget {
  //final IkChatBotConfig  chatBotConfig;

  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final bool _chatIsOpened = false;
  @override
  Widget build(BuildContext context) {
    final chatBotConfig = IkChatBotConfig(
      ratingIconYes: const Icon(Icons.star),
      ratingIconNo: const Icon(Icons.star_border),
      ratingIconColor: Colors.black,
      ratingBackgroundColor: Colors.white,
      ratingButtonText: 'Đánh giá đoạn chat',
      thankyouText: 'Cảm ơn vì đánh giá của bạn!',
      ratingText: 'Đánh giá trải nghiệm của bạn:',
      ratingTitle: 'Cảm ơn bạn đã sử dụng chức năng của chúng tôi!',
      body: 'Khách Hàng đã đánh giá cuộc trò chuyện',
      subject: 'Đánh giá',
      recipient: 'duyanhtongapplyit@gmail.com',
      isSecure: false,
      senderName: 'Khách Hàng',
      smtpUsername: 'duyanhtongapplyit@gmail.com',
      smtpPassword: 'dbot zlsl oojp nbrf',
      smtpServer: 'smtp.gmail.com',
      smtpPort: 587,
      //Settings to your system Configurations
      sendIcon: const Icon(Icons.send, color: Colors.red),
      userIcon: const Icon(Icons.person_2_rounded, color: Colors.white),
      botIcon: const Icon(Icons.android, color: Colors.white),
      botChatColor: const Color.fromARGB(255, 104, 0, 101),
      delayBot: 100,
      closingTime: 1,
      delayResponse: 1,
      userChatColor: const Color.fromARGB(255, 103, 0, 0),
      waitingTime: 1,
      keywords: keywords,
      responses: responses,
      backgroundColor: Colors.white,
      backgroundImage:
          'https://www.google.com/imgres?imgurl=https%3A%2F%2Fbillboardquangcao.com%2Fuploads%2Fproducts%2Fhinh-nen-trang-4k-1024x600.jpg&tbnid=9mhM4jC6unkxSM&vet=12ahUKEwjp7-OUjJGGAxVYWvUHHSmvDfYQMygAegQIARBP..i&imgrefurl=https%3A%2F%2Frdsic.edu.vn%2Fblog%2Ftoan%2Fnhung-diem-khac-nhau-giua-cac-mau-trang-hinh-nen-khi-thiet-ke-website-vi-cb.html&docid=xO-gRn3da3BzBM&w=1024&h=600&q=%E1%BA%A3nh%20n%E1%BB%81n%20tr%E1%BA%AFng%204k&ved=2ahUKEwjp7-OUjJGGAxVYWvUHHSmvDfYQMygAegQIARBP',
      backgroundAssetimage: "assets/images/bgwhite.png",
      initialGreeting:
          "Xin chào \nChào mừng bạn đến với cửa hàng Mưa Pet\nCửa hàng rất hân hạnh được phục vụ bạn!",

      defaultResponse: "Xin lỗi, tôi không hiểu câu trả lời của bạn.",
      inactivityMessage: "Bạn còn cần trợ giúp gì nữa không?",
      closingMessage: "Cuộc trò chuyện này bây giờ sẽ kết thúc.",
      inputHint: 'Nhập tin nhắn',
      waitingText: 'Vui lòng chờ...',
      useAsset: false,
    );
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Trò chuyện tự động',
            style: TextStyle(color: kPrimaryColor, fontSize: 16.0),
          ),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ),
        body: _chatIsOpened
            ? const Center(
                child: Text('Chào mừng đến với cửa hàng Mưa Pet'),
              )
            : ikchatbot(config: chatBotConfig));
  }
}
