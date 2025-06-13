import '/exports.dart';
import 'dart:math';

class ABTestingService extends GetxService {
  final experiments = <String, ABTestExperiment>{}.obs;
  final userVariants = <String, String>{}.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadExperiments();
    await _loadUserVariants();
  }

  Future<void> _loadExperiments() async {
    // In a real implementation, you would load from a remote config service
    // For now, we'll set up some example experiments
    experiments.value = {
      'checkout_button_color': ABTestExperiment(
        id: 'checkout_button_color',
        name: 'Checkout Button Color Test',
        variants: ['blue', 'green', 'orange'],
        traffic: 0.5, // 50% of users
        isActive: true,
      ),
      'product_card_layout': ABTestExperiment(
        id: 'product_card_layout',
        name: 'Product Card Layout Test',
        variants: ['compact', 'detailed'],
        traffic: 0.3, // 30% of users
        isActive: true,
      ),
      'search_suggestions': ABTestExperiment(
        id: 'search_suggestions',
        name: 'Search Suggestions Test',
        variants: ['basic', 'enhanced'],
        traffic: 0.8, // 80% of users
        isActive: false,
      ),
    };
  }

  Future<void> _loadUserVariants() async {
    // Load user's assigned variants from local storage
    try {
      final storage = GetStorage();
      final savedVariants = storage.read('ab_test_variants') as Map<String, dynamic>?;
      if (savedVariants != null) {
        userVariants.value = Map<String, String>.from(savedVariants);
      }
    } catch (e) {
      AppHelpers.logError('Failed to load user variants: $e');
    }
  }

  Future<void> _saveUserVariants() async {
    try {
      final storage = GetStorage();
      await storage.write('ab_test_variants', userVariants);
    } catch (e) {
      AppHelpers.logError('Failed to save user variants: $e');
    }
  }

  String getVariant(String experimentId) {
    // Check if user already has a variant for this experiment
    if (userVariants.containsKey(experimentId)) {
      return userVariants[experimentId]!;
    }

    final experiment = experiments[experimentId];
    if (experiment == null || !experiment.isActive) {
      return 'control'; // Default variant
    }

    // Check if user should be included in this experiment
    final random = Random();
    if (random.nextDouble() > experiment.traffic) {
      return 'control';
    }

    // Assign random variant
    final variantIndex = random.nextInt(experiment.variants.length);
    final assignedVariant = experiment.variants[variantIndex];

    // Save the assignment
    userVariants[experimentId] = assignedVariant;
    _saveUserVariants();

    // Track the assignment
    _trackExperimentAssignment(experimentId, assignedVariant);

    return assignedVariant;
  }

  bool isInExperiment(String experimentId) {
    return userVariants.containsKey(experimentId) && userVariants[experimentId] != 'control';
  }

  void trackConversion(String experimentId, String event, {Map<String, dynamic>? properties}) {
    if (!isInExperiment(experimentId)) return;

    final variant = userVariants[experimentId];

    // In a real implementation, you would send this to an analytics service
    AppHelpers.logInfo('A/B Test Conversion - Experiment: $experimentId, Variant: $variant, Event: $event');

    // Track with Firebase Analytics or your preferred analytics service
    // FirebaseAnalytics.instance.logEvent(
    //   name: 'ab_test_conversion',
    //   parameters: {
    //     'experiment_id': experimentId,
    //     'variant': variant,
    //     'event': event,
    //     ...?properties,
    //   },
    // );
  }

  void _trackExperimentAssignment(String experimentId, String variant) {
    AppHelpers.logInfo('A/B Test Assignment - Experiment: $experimentId, Variant: $variant');

    // Track assignment with analytics service
    // FirebaseAnalytics.instance.logEvent(
    //   name: 'ab_test_assignment',
    //   parameters: {
    //     'experiment_id': experimentId,
    //     'variant': variant,
    //   },
    // );
  }

  // Utility methods for common experiments
  Color getCheckoutButtonColor() {
    final variant = getVariant('checkout_button_color');
    switch (variant) {
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'blue':
      default:
        return Colors.blue;
    }
  }

  bool useDetailedProductCard() {
    return getVariant('product_card_layout') == 'detailed';
  }

  bool useEnhancedSearchSuggestions() {
    return getVariant('search_suggestions') == 'enhanced';
  }

  // Admin methods (for testing purposes)
  void forceVariant(String experimentId, String variant) {
    userVariants[experimentId] = variant;
    _saveUserVariants();
  }

  void clearUserVariants() {
    userVariants.clear();
    _saveUserVariants();
  }

  List<ABTestExperiment> getActiveExperiments() {
    return experiments.values.where((exp) => exp.isActive).toList();
  }
}

class ABTestExperiment {
  final String id;
  final String name;
  final List<String> variants;
  final double traffic; // 0.0 to 1.0
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;

  ABTestExperiment({
    required this.id,
    required this.name,
    required this.variants,
    required this.traffic,
    required this.isActive,
    this.startDate,
    this.endDate,
  });

  bool get isRunning {
    if (!isActive) return false;

    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;

    return true;
  }
}
