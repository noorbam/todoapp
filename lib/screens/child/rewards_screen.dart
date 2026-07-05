import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reward_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/reward_card.dart';
import '../../widgets/coin_counter.dart';

class RewardsScreen extends StatefulWidget {
  final bool isTab;
  const RewardsScreen({super.key, this.isTab = false});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final child = context.read<AuthProvider>().currentUser;
      if (child != null) {
        context.read<RewardProvider>().listenToRewards(child.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final rewardProvider = context.watch<RewardProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final rewards = rewardProvider.rewards;
    final currentCoins = progressProvider.points;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  if (!widget.isTab)
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryStrong),
                    ),
                  Expanded(
                    child: Text(
                      AppStrings.get(context, 'rewardsShop'),
                      style: GoogleFonts.cairo(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  CoinCounter(coins: currentCoins, fontSize: 18),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.rewardGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.rewardColor.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 48)),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$currentCoins ${AppStrings.get(context, 'coins')}',
                          style: GoogleFonts.cairo(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          AppStrings.get(context, 'coinsAvailable'),
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: rewardProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryStrong))
                  : rewards.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('😢', style: TextStyle(fontSize: 72))
                                  .animate()
                                  .scale(begin: const Offset(0, 0), duration: 500.ms, curve: Curves.elasticOut),
                              const SizedBox(height: 24),
                              Text(
                                AppStrings.get(context, 'noRewardsYet'),
                                style: GoogleFonts.cairo(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                AppStrings.get(context, 'noRewardsHint'),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: rewards.length,
                          itemBuilder: (context, index) {
                            final reward = rewards[index];
                            return RewardCard(
                              reward: reward,
                              currentCoins: currentCoins,
                              onRedeem: () => _redeemReward(context, reward, currentCoins),
                            ).animate(delay: (index * 80).ms).fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9));
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _redeemReward(BuildContext context, reward, int currentCoins) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(AppStrings.get(context, 'redeemReward'),
            style: GoogleFonts.cairo(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900)),
        content: Text(
          'Spend ${reward.cost} 🪙 ${AppStrings.get(context, 'coins')} for "${reward.title}"?',
          style: GoogleFonts.cairo(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.get(context, 'cancel'),
                style: GoogleFonts.cairo(color: AppColors.textSub, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryStrong,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(AppStrings.get(context, 'redeem'),
                style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await context.read<RewardProvider>().redeemReward(reward, currentCoins);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? AppStrings.get(context, 'redeemSuccess')
              : AppStrings.get(context, 'notEnoughCoins')),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }
}
