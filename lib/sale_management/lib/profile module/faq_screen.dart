import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'question': 'What is Sales ERP?',
      'answer':
      'Sales ERP is an integrated system to manage your sales, inventory, orders, and customer data all in one place.',
    },
    {
      'question': 'How can I create a new order?',
      'answer':
      'Go to the Orders section from the home screen and tap on the "+" button to create a new order.',
    },
    {
      'question': 'How will I receive notifications?',
      'answer':
      'You can manage your notification preferences in the Notification settings screen under your Profile.',
    },
    {
      'question': 'How do I track sales reports?',
      'answer':
      'Navigate to the Reports section from the dashboard to view detailed sales analytics and reports.',
    },
    {
      'question': 'Can I update customer details?',
      'answer':
      'Yes, go to the Customers section, select the customer, and tap Edit to update their information.',
    },
  ];

  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.bgCard,
      appBar: AppBar(
        title: const Text('FAQ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.05,
          vertical: h * 0.03,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Frequently Asked Questions', style: AppTextStyles.heading2),
            SizedBox(height: h * 0.025),
            Expanded(
              child: ListView.separated(
                itemCount: _faqs.length,
                separatorBuilder: (_, __) => SizedBox(height: h * 0.015),
                itemBuilder: (context, index) {
                  final isExpanded = _expandedIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _expandedIndex = isExpanded ? null : index;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.045,
                        vertical: h * 0.018,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _faqs[index]['question']!,
                                  style: AppTextStyles.sectionTitle.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: AppColors.textDark,
                              ),
                            ],
                          ),
                          if (isExpanded) ...[
                            SizedBox(height: h * 0.012),
                            Divider(color: AppColors.divider, height: 1),
                            SizedBox(height: h * 0.012),
                            Text(
                              _faqs[index]['answer']!,
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.textLight,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}