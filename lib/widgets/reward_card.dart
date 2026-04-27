import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/reward_model.dart';
import '../core/constants/app_colors.dart';

/// Reward shop card — shows a reward item with coin cost and redeem button
class RewardCard extends StatelessWidget {
  final RewardModel reward;
  final int currentCoins;
  final VoidCallback? onRedeem;

  const RewardCard({
    super.key,
    required this.reward,
    required this.currentCoins,
    this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = currentCoins >= reward.cost;
    final isRedeemed = reward.isRedeemed;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isRedeemed
              ? [Colors.grey.shade200, Colors.grey.shade300]
              : AppColors.rewardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isRedeemed)
            BoxShadow(
              color: AppColors.rewardColor.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji icon
            Text(
              reward.iconName,
              style: TextStyle(fontSize: isRedeemed ? 40 : 52),
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              reward.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: isRedeemed ? AppColors.textSub : AppColors.textMain,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Cost badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '🪙 ${reward.cost}',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isRedeemed ? AppColors.textSub : AppColors.textMain,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Redeem / Redeemed button
            if (isRedeemed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '✅ Got it!',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSub,
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canAfford ? onRedeem : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.rewardColor,
                    elevation: canAfford ? 2 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    canAfford ? '✨ Claim!' : '🔒 ${reward.cost - currentCoins} more',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
