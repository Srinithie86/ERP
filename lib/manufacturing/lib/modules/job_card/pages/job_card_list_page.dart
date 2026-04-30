import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../job_card_model.dart';
import '../widgets/job_card_widgets.dart';
import 'job_card_detail_page.dart';

class JobCardListPage extends StatelessWidget {
  const JobCardListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView.separated(
        padding: EdgeInsets.all(sw * 0.05),
        itemCount: JobCardSampleData.jobCards.length,
        separatorBuilder: (_, __) => SizedBox(height: sw * 0.03),
        itemBuilder: (_, i) => JCJobCardTile(
          job: JobCardSampleData.jobCards[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => JobCardDetailPage(job: JobCardSampleData.jobCards[i])),
          ),
        ),
      ),
    );
  }
}
