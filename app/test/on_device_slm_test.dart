import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_lining_app/config/app_config.dart';
import 'package:silver_lining_app/services/local_safety_service.dart';
import 'package:silver_lining_app/services/model_manager_service.dart';
import 'package:silver_lining_app/services/on_device_reframing_service.dart';
import 'package:silver_lining_app/widgets/cards/ai_model_status_card.dart';

void main() {
  group('LocalSafetyService (<1ms Pure-Dart 3-Tier Safety Shield)', () {
    test('Tier 1: detects self-harm crisis keywords across EN, UK, ES, DE, FR', () {
      final enCrisis = LocalSafetyService.evaluateInputSafety(
        'Everything feels hopeless and I want to hurt myself tonight',
      );
      expect(enCrisis, isNotNull);
      expect(enCrisis!.crisisTriggered, isTrue);
      expect(enCrisis.emergencyHotline, equals('988'));
      expect(enCrisis.safetyCategory, equals('self_harm_crisis'));

      final ukCrisis = LocalSafetyService.evaluateInputSafety(
        'Мені так важко, я більше не хочу жити',
      );
      expect(ukCrisis, isNotNull);
      expect(ukCrisis!.crisisTriggered, isTrue);

      final esCrisis = LocalSafetyService.evaluateInputSafety(
        'Me siento muy mal y pienso en quitarme la vida',
      );
      expect(esCrisis, isNotNull);
      expect(esCrisis!.crisisTriggered, isTrue);

      final deCrisis = LocalSafetyService.evaluateInputSafety(
        'Ich will mein leben beenden',
      );
      expect(deCrisis, isNotNull);
      expect(deCrisis!.crisisTriggered, isTrue);

      final frCrisis = LocalSafetyService.evaluateInputSafety(
        'Je veux mettre fin à mes jours',
      );
      expect(frCrisis, isNotNull);
      expect(frCrisis!.crisisTriggered, isTrue);
    });

    test('Tier 2: detects crime/illegal patterns across EN, UK, ES without false positives', () {
      final enCrime = LocalSafetyService.evaluateInputSafety(
        'I stole money from the register at work today',
      );
      expect(enCrime, isNotNull);
      expect(enCrime!.isSafe, isFalse);
      expect(enCrime.safetyCategory, equals('crime_refusal'));

      final ukCrime = LocalSafetyService.evaluateInputSafety(
        'Підкажи як зламати чужий акаунт',
      );
      expect(ukCrime, isNotNull);
      expect(ukCrime!.isSafe, isFalse);

      final esCrime = LocalSafetyService.evaluateInputSafety(
        'Quiero saber cómo hackear una cuenta',
      );
      expect(esCrime, isNotNull);
      expect(esCrime!.isSafe, isFalse);

      // Victim of hacking should NOT be flagged as a crime perpetrator
      final safeVictim = LocalSafetyService.evaluateInputSafety(
        'My email account was hacked yesterday and I feel stressed',
      );
      expect(safeVictim, isNull);
    });

    test('Detects fine-tuned model output safety refusals across languages', () {
      expect(
        LocalSafetyService.isModelOutputRefusal(
          'I understand you feel guilty, but **I cannot help you with this request.**',
        ),
        isTrue,
      );
      expect(
        LocalSafetyService.isModelOutputRefusal(
          'Я не можу допомогти з цим запитом.',
        ),
        isTrue,
      );
      expect(
        LocalSafetyService.isModelOutputRefusal(
          'Missing a deadline is stressful, but it shows how much you care about your work.',
        ),
        isFalse,
      );
    });
  });

  group('OnDeviceReframingService & ModelManagerService', () {
    final manager = ModelManagerService.instance;

    tearDown(() async {
      await manager.unloadAndDeleteCache();
    });

    test('Verifies Hugging Face CDN metadata & Gemma 3 prompt template', () {
      expect(
        AppConfig.hfModelDownloadUrl(AppConfig.compactModelFileName),
        equals(
          'https://huggingface.co/ihor-matiushenko/silver-lining-gemma3-gguf/resolve/main/silver-lining-270m-q4_k_m.gguf',
        ),
      );
      expect(OnDeviceModelTier.compact.expectedBytes, equals(261317920));
      expect(OnDeviceModelTier.pro.expectedBytes, equals(299748640));

      final prompt = OnDeviceReframingService.buildGemmaPrompt(
        'Я дуже втомився на роботі',
        targetLanguage: 'uk',
      );
      expect(
        prompt,
        equals(
          '<start_of_turn>user\n[SilverLining | lang=uk]\nЯ дуже втомився на роботі<end_of_turn>\n<start_of_turn>model\n',
        ),
      );
    });

    test('Executes 100% offline inference and gray-area refusal detection when ready', () async {
      manager.setDebugGenerator((prompt) async {
        if (prompt.contains(r'$50')) {
          return 'I understand that you are feeling guilty, but **I cannot help you with this request.**<end_of_turn>';
        }
        return 'Taking a breath after a busy day helps you recharge and notice how much you accomplished.<end_of_turn>';
      });

      final service = OnDeviceReframingService(
        modelManager: manager,
        fallbackToCloudWhenNotReady: false,
      );

      // 1. Safe reframing
      final resSafe = await service.reframeThought(
        'I had an exhausting day of meetings',
        targetLanguage: 'en',
      );
      expect(resSafe.isSafe, isTrue);
      expect(resSafe.crisisTriggered, isFalse);
      expect(
        resSafe.reframedText,
        equals(
          'Taking a breath after a busy day helps you recharge and notice how much you accomplished.',
        ),
      );

      // 2. Gray-area theft prompt refused by fine-tuned weights
      final resGray = await service.reframeThought(
        r"I took $50 from my roommate's wallet without asking and feel guilty",
        targetLanguage: 'en',
      );
      expect(resGray.isSafe, isFalse);
      expect(resGray.safetyCategory, equals('crime_refusal'));
      expect(resGray.reframedText, isNull);
    });

    testWidgets('AiModelStatusCard renders download CTA and active offline badge', (tester) async {
      await manager.unloadAndDeleteCache();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AiModelStatusCard(),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('ai_model_status_card')), findsOneWidget);
      expect(find.byKey(const ValueKey('download_offline_brain_button')), findsOneWidget);

      // Transition to ready state
      manager.setDebugGenerator((_) async => 'Reframed offline.');
      await tester.pump();

      expect(find.byKey(const ValueKey('on_device_active_badge')), findsOneWidget);
      expect(find.textContaining('On-Device AI Active'), findsOneWidget);
    });
  });
}
