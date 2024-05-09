import 'package:flutter/material.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/feedback.model.dart';
import 'package:shop_app/services/api.dart';

class ListProductReviewScreen extends StatefulWidget {
  final int productId;

  const ListProductReviewScreen({Key? key, required this.productId})
      : super(key: key);

  @override
  State<ListProductReviewScreen> createState() =>
      _ListProductReviewScreenState();
}

class _ListProductReviewScreenState extends State<ListProductReviewScreen> {
  late Future<List<FeedbackModel>> _feedbacksFuture;
  List<FeedbackModel> _feedbacks = [];
  ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  int _currentPage = 1; // 현재 페이지를 추적합니다.

  @override
  void initState() {
    super.initState();
    _feedbacksFuture = _getListFeedback();
    _scrollController.addListener(_onScroll);
  }

  Future<List<FeedbackModel>> _getListFeedback() async {
    try {
      final feedbacks = await Api.getListFeedbackPublic(
        status: 'reviewed',
        product_id: widget.productId,
        page: _currentPage, // API 호출 시 현재 페이지 번호를 포함합니다.
      );
      setState(() {
        _currentPage++; // 성공적으로 데이터를 받아온 후 페이지 번호를 증가시킵니다.
        _isLoading = false; // 로딩 상태를 false로 설정합니다.
        _feedbacks.addAll(feedbacks); // 새로운 피드백을 기존 리스트에 추가합니다.
      });
      return _feedbacks;
    } catch (error) {
      print('Error fetching feedbacks: $error');
      throw error;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading) {
        // 추가 데이터 로딩 중이 아니라면
        _isLoading = true; // 로딩 상태를 true로 변경합니다.
        _getListFeedback(); // 추가 데이터를 로드합니다.
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // 컨트롤러를 정리합니다.
    super.dispose();
  }

  Widget buildFeedbackCard(FeedbackModel feedback) {
    return Card(
      child: ListTile(
        title: Row(
          children: [
            if (feedback.rating != null)
              Row(
                children: List.generate(
                  feedback.rating!.round(),
                  (index) => const Icon(Icons.star, color: kPrimaryColor),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (feedback.image != null)
              Image.network(
                feedback.image!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            if (feedback.comment != null) Text(feedback.comment!),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FeedbackModel>>(
      future: _feedbacksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (snapshot.hasData) {
          return ListView.builder(
            controller: _scrollController,
            itemCount: _feedbacks.length,
            itemBuilder: (context, index) {
              final feedback = _feedbacks[index];
              return buildFeedbackCard(feedback);
            },
          );
        } else {
          return const Center(
            child: Text('Không có feedback nào'),
          );
        }
      },
    );
  }
}
