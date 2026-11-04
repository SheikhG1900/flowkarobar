import 'package:flowpaisa/features/businesses/presentation/providers/business_provider.dart';

export 'package:flowpaisa/features/businesses/presentation/providers/business_provider.dart';

typedef CashbookNotifier = BusinessNotifier;
typedef ActiveCashbookIdNotifier = ActiveBusinessIdNotifier;

final cashbooksProvider = businessesProvider;
final activeCashbookIdProvider = activeBusinessIdProvider;
final activeCashbookProvider = activeBusinessProvider;
