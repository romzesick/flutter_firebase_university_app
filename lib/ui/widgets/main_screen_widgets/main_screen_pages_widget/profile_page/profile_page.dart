import 'package:firebase_flutter_app/ui/components/radial_progress_bar/progres_bar.dart';
import 'package:firebase_flutter_app/ui/components/time_progress_bar/time_progress_bar.dart';
import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/profile_page/achieved_goals/goals_achieved.dart';
import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/profile_page/daily_revard/daily_reward.dart';
import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/profile_page/friends/friends_progress_widget.dart';
import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/profile_page/settings_page/settings_page.dart';
import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/profile_page/view_rangs/view_rangs_widget.dart';
import 'package:firebase_flutter_app/view_models/goals_view_models/goals_view_model.dart';
import 'package:firebase_flutter_app/view_models/profile_view_models/main_info_view_model.dart';
import 'package:firebase_flutter_app/view_models/profile_view_models/ranks_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static Widget create() {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel()..loadProfileData(),
      child: const ProfilePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: ListView(
        children: [
          _PersonalInfoProgressWidgets(),
          SizedBox(height: 20),
          FriendsProgressWidget(),
          SizedBox(height: 20),
          ChangeNotifierProvider(
            create: (_) => RankViewModel()..loadRanks(),
            child: _ScoreWidget(),
          ),
          SizedBox(height: 20),
          _DailyRewardWidget(),
          SizedBox(height: 20),
          Row(
            children: [
              _SettingsWidget(),
              SizedBox(width: 20),
              Expanded(child: _GoalsAchieved()),
            ],
          ),
        ],
      ),
    );
  }
}

class _PersonalInfoProgressWidgets extends StatelessWidget {
  const _PersonalInfoProgressWidgets();

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileViewModel>();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                height: 70,
                width: 70,
                child:
                    profile.isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                        : RadialPercentWidget(
                          percent: profile.averageProductivity,
                          fillColor: Colors.white30,
                          freeColor: Colors.white70,
                          lineWidth: 7,
                          child: Text(
                            '${(profile.averageProductivity * 100).toInt()}%',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  profile.isLoading
                      ? 'Loading...'
                      : 'Welcome back, ${profile.userName}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TimeProgressBar(label: 'Year', percent: profile.yearProgress),
          const SizedBox(height: 5),
          TimeProgressBar(label: 'Month', percent: profile.monthProgress),
          const SizedBox(height: 5),
          TimeProgressBar(label: 'Day', percent: profile.dayProgress),
        ],
      ),
    );
  }
}

class _GoalsAchieved extends StatelessWidget {
  const _GoalsAchieved();

  @override
  Widget build(BuildContext context) {
    final model = context.read<GoalsViewModel>();

    final achievedGoals = model.goals.where((g) => g.completed).toList();
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GoalsAchievedWidget()),
        );
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Goals achieved',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 10),
              Text(
                '${achievedGoals.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsWidget extends StatelessWidget {
  const _SettingsWidget();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsPageWidget()),
          ),
      child: Container(
        height: 60,
        width: 120,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Settings', style: TextStyle(color: Colors.white)),
            SizedBox(width: 10),
            Icon(Icons.settings, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _DailyRewardWidget extends StatelessWidget {
  const _DailyRewardWidget();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => const DailyRewardPopup(),
        );
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.calendar_month, color: Colors.white),
            SizedBox(width: 10),
            Text('Daily reward', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _ScoreWidget extends StatelessWidget {
  const _ScoreWidget();

  @override
  Widget build(BuildContext context) {
    final rankModel = context.watch<RankViewModel>();

    if (rankModel.isLoading) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final rankName = rankModel.userRank?.name ?? 'Unranked';
    final totalPoints = rankModel.userPoints ?? 0;

    return Stack(
      children: [
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const Positioned(
          left: 10,
          top: 10,
          child: Text('Your Score', style: TextStyle(color: Colors.white)),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Row(
            children: [
              Text(
                '$totalPoints 🎯',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 10,
          bottom: 10,
          child: Text(
            rankName,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: ElevatedButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                Color.fromARGB(255, 43, 41, 41),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewRangsWidget.create(),
                ),
              );
            },
            child: const Text(
              'View rangs',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
