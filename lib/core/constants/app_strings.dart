import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class AppStrings {
  static String get(BuildContext context, String key) {
    final isArabic = Provider.of<LanguageProvider>(context, listen: false).isArabic;
    return isArabic ? (_ar[key] ?? key) : (_en[key] ?? key);
  }

  // Roles
  static const String parentRole = 'parent';
  static const String childRole = 'child';

  // Status
  static const String pending = 'pending';
  static const String completed = 'completed';
  static const String approved = 'approved';
  static const String rejected = 'rejected';

  static const Map<String, String> _en = {
    'appName': 'KidQuest',
    'tagline': 'Missions. Rewards. Adventure!',
    'signInParent': 'Sign in with Google',
    'iAmAChild': "I'm a Kid! 🎮",
    'parentHint': 'Parents use Google Sign-In to manage tasks',
    'welcomeParent': 'Welcome, Parent! 👋',
    'setupAccount': "Let's set up your account",
    'parentAccount': 'Parent Account',
    'parentDesc': 'Create missions • Approve tasks • Track progress',
    'yourName': 'Your Name',
    'letsGo': "Let's Go! 🚀",
    'chooseHero': 'Choose Your Hero! ⚔️',
    'enterPin': 'Enter Your PIN',
    'wrongPin': 'Wrong PIN! Try again 🔒',
    'letsPlay': "Let's Play! 🎮",
    'noHeroes': 'No heroes yet!\nAsk a parent to create your account.',
    'addHero': 'Add Hero',
    'heroName': "Hero's Name",
    'pin4': '4-digit PIN',
    'chooseAvatar': 'Choose Avatar:',
    'createHero': 'Create Hero!',
    'cancel': 'Cancel',
    'heroReady': 'is ready to quest! 🎉',
    'myHeroes': 'My Heroes 🏆',
    'approvals': 'Approvals',
    'signOut': 'Sign Out',
  };

  static const Map<String, String> _ar = {
    'appName': 'مهمة البطل',
    'tagline': 'مهام. جوائز. مغامرة! 🚀',
    'signInParent': 'الدخول عبر جوجل (للآباء)',
    'iAmAChild': 'أنا بطل صغير! 🎮',
    'parentHint': 'الآباء يستخدمون جوجل لإدارة المهام',
    'welcomeParent': 'أهلاً بك أيها الأب! 👋',
    'setupAccount': 'لنقم بإعداد حسابك',
    'parentAccount': 'حساب الأب',
    'parentDesc': 'إنشاء المهام • الموافقة • متابعة التقدم',
    'yourName': 'اسمك',
    'letsGo': 'هيا بنا! 🚀',
    'chooseHero': 'اختر بطلك! ⚔️',
    'enterPin': 'أدخل الرمز السري',
    'wrongPin': 'الرمز خاطئ! حاول مجدداً 🔒',
    'letsPlay': 'هيا نلعب! 🎮',
    'noHeroes': 'لا يوجد أبطال بعد!\nاطلب من والدك إنشاء حساب لك.',
    'addHero': 'إضافة بطل',
    'heroName': 'اسم البطل',
    'pin4': 'رمز سري (4 أرقام)',
    'chooseAvatar': 'اختر الأفاتار:',
    'createHero': 'إنشاء البطل!',
    'cancel': 'إلغاء',
    'heroReady': 'جاهز للمغامرة! 🎉',
    'myHeroes': 'أبطالي 🏆',
    'approvals': 'الطلبات',
    'signOut': 'تسجيل الخروج',
  };
}
