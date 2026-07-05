import 'package:flutter/material.dart';
import '../models/reward_model.dart';
import '../services/firestore_service.dart';

/// RewardProvider — manages the reward shop for a child
class RewardProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<RewardModel> _rewards = [];
  bool _isLoading = false;
  String? _error;

  // ── Getters ───────────────────────────────────────────────────────────────

  List<RewardModel> get rewards => _rewards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Stream ────────────────────────────────────────────────────────────────

  void listenToRewards(String childId) {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getRewardsStream(childId).listen(
      (rewards) {
        _rewards = rewards;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<bool> redeemReward(RewardModel reward, int currentCoins) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success =
          await _firestoreService.redeemReward(reward, currentCoins);
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<bool> createReward({
    required String title,
    String? description,
    required int cost,
    String iconName = '🎁',
    required String childId,
    required String parentId,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.createReward(
        title: title,
        description: description,
        cost: cost,
        iconName: iconName,
        childId: childId,
        parentId: parentId,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteReward(String rewardId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.deleteReward(rewardId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
