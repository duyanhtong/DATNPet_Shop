import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_app/components/custom_dialog.dart';
import 'package:shop_app/models/user.model.dart';
import 'package:shop_app/services/api.dart';

class ProfilePic extends StatefulWidget {
  const ProfilePic({Key? key}) : super(key: key);

  @override
  State<ProfilePic> createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> {
  late Future<UserModel?> futureProfilePic;
  File? selectedImage;
  @override
  void initState() {
    super.initState();
    futureProfilePic = getProfilePic();
  }

  Future<UserModel?> getProfilePic() async {
    try {
      var profile = await Api.getProfile();

      if (profile != null) {
        return profile;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: source);
    if (result != null) {
      setState(() {
        selectedImage = File(result.path);
      });
      showPreviewDialog(context);
    }
  }

  void showPreviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận ảnh đại diện'),
          content: SizedBox(
            height: 200,
            child: selectedImage != null
                ? Image.file(selectedImage!)
                : const Text('Chưa chọn ảnh'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy bỏ'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                final userId = await _getUserIdFromFuture();

                if (userId != null) {
                  String? uploadResult =
                      await Api.uploadImage(userId, selectedImage!);
                  if (uploadResult == "OK") {
                    setState(() {
                      futureProfilePic = getProfilePic();
                    });
                  } else {
                    showCustomDialog(
                        context, "Cập nhật ảnh", "Cập nhật ảnh lỗi");
                  }
                } else {
                  showCustomDialog(
                      context, "Cập nhật ảnh", "Bạn cần đăng nhập tài khoản!");
                  print('Error: User ID not available for upload');
                }
              },
              child: Text('Tải lên'),
            ),
          ],
        );
      },
    );
  }

  Future<int?> _getUserIdFromFuture() async {
    // Extract user ID from futureProfilePic (assuming it contains a UserModel)
    final user = await futureProfilePic;

    if (user != null) {
      return user.id; // Return user ID
    } else {
      return null; // Handle case where user data is unavailable
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: futureProfilePic,
      builder: (context, snapshot) {
        Widget profileImage;
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Hiển thị một placeholder khi đang tải
          profileImage = const CircleAvatar(
            backgroundImage: AssetImage("assets/images/2.png"),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          // Hiển thị hình ảnh mặc định nếu có lỗi hoặc không có dữ liệu
          profileImage = const CircleAvatar(
            backgroundImage: AssetImage("assets/images/2.png"),
          );
        } else {
          final user = snapshot.data!;
          profileImage = CircleAvatar(
            backgroundImage: NetworkImage(user.image!),
          );
        }

        return SizedBox(
          height: 115,
          width: 115,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              profileImage,
              Positioned(
                right: -16,
                bottom: 0,
                child: SizedBox(
                  height: 46,
                  width: 46,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                        side: const BorderSide(color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFFF5F6F9),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Wrap(
                            children: [
                              ListTile(
                                leading: Icon(Icons.camera_alt),
                                title: Text('Chụp ảnh'),
                                onTap: () => pickImage(ImageSource.camera),
                              ),
                              ListTile(
                                leading: Icon(Icons.photo_library),
                                title: Text('Chọn ảnh từ thư viện'),
                                onTap: () => pickImage(ImageSource.gallery),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: SvgPicture.asset("assets/icons/Camera Icon.svg"),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
