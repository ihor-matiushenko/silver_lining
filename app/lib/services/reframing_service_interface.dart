import '../models/reframe_response.dart';

/// 🔌 Abstract Interface defining the contract for Reframing Services.
/// Both MockReframingService and ApiReframingService will implement this contract!
abstract class ReframingServiceInterface {
  Future<ReframeResponse> reframeThought(String inputText);
}
