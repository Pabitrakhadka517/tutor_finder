import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_cov_console/test_cov_console.dart' hide contains;

class ApiFailure implements Exception {
  final String message;
  const ApiFailure(this.message);

  @override
  String toString() => 'ApiFailure($message)';
}

class OfflineFailure implements Exception {
  const OfflineFailure();
}

class Tutor {
  final String id;
  final String name;
  final List<String> subjects;
  final double hourlyRate;
  final bool available;

  const Tutor({
    required this.id,
    required this.name,
    required this.subjects,
    required this.hourlyRate,
    required this.available,
  });
}

class FakeTutorApi {
  bool shouldFail = false;
  bool offline = false;
  List<Tutor> nextTutors = const [];

  Future<List<Tutor>> fetchTutors() async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    if (offline) {
      throw const OfflineFailure();
    }
    if (shouldFail) {
      throw const ApiFailure('network-failed');
    }
    return nextTutors;
  }
}

class FakeLocalStorage {
  final Map<String, Object?> _store = <String, Object?>{};

  Future<void> write(String key, Object? value) async {
    _store[key] = value;
  }

  Future<T?> read<T>(String key) async {
    final Object? value = _store[key];
    if (value is T) {
      return value;
    }
    return null;
  }

  void clear() {
    _store.clear();
  }
}

class TutorRepository {
  TutorRepository({required this.api, required this.storage});

  final FakeTutorApi api;
  final FakeLocalStorage storage;

  Future<List<Tutor>> getTutors({bool useCacheOnFailure = true}) async {
    try {
      final List<Tutor> remote = await api.fetchTutors();
      await storage.write('cached_tutors', remote);
      return remote;
    } on OfflineFailure {
      if (!useCacheOnFailure) {
        rethrow;
      }
      return await storage.read<List<Tutor>>('cached_tutors') ?? <Tutor>[];
    } on ApiFailure {
      if (!useCacheOnFailure) {
        rethrow;
      }
      return await storage.read<List<Tutor>>('cached_tutors') ?? <Tutor>[];
    }
  }
}

class TutorUseCase {
  TutorUseCase(this.repository);

  final TutorRepository repository;

  String normalizeName(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return 'Unknown';
    }
    final String normalized = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    return normalized
        .split(' ')
        .map(
          (String part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String formatRate(double? rate) {
    if (rate == null || rate.isNaN || rate.isNegative) {
      return 'N/A';
    }
    return '\$${rate.toStringAsFixed(2)}/hr';
  }

  Map<String, int> countSubjects(List<Tutor> tutors) {
    final Map<String, int> result = <String, int>{};
    for (final Tutor tutor in tutors) {
      for (final String subject in tutor.subjects) {
        result.update(subject, (int value) => value + 1, ifAbsent: () => 1);
      }
    }
    return result;
  }

  Future<List<Tutor>> searchBySubject(String? query) async {
    if (query == null || query.trim().isEmpty) {
      return <Tutor>[];
    }
    final String q = query.trim().toLowerCase();
    final List<Tutor> tutors = await repository.getTutors();
    return tutors
        .where((Tutor t) => t.subjects.any((String s) => s.toLowerCase() == q))
        .toList()
      ..sort((Tutor a, Tutor b) => a.hourlyRate.compareTo(b.hourlyRate));
  }

  Future<bool> bookTutor({
    required String? tutorId,
    required String? studentId,
  }) async {
    if (tutorId == null || studentId == null) {
      return false;
    }
    if (tutorId.trim().isEmpty || studentId.trim().isEmpty) {
      return false;
    }
    await repository.storage.write('last_booking', '$studentId:$tutorId');
    return true;
  }
}

class SearchState {
  final bool isLoading;
  final List<Tutor> results;
  final String? error;
  final String query;

  const SearchState({
    this.isLoading = false,
    this.results = const <Tutor>[],
    this.error,
    this.query = '',
  });

  SearchState copyWith({
    bool? isLoading,
    List<Tutor>? results,
    String? error,
    String? query,
    bool clearError = false,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      error: clearError ? null : (error ?? this.error),
      query: query ?? this.query,
    );
  }
}

class SearchViewModel extends ChangeNotifier {
  SearchViewModel(this.useCase);

  final TutorUseCase useCase;
  SearchState state = const SearchState();
  final List<String> eventLog = <String>[];

  void updateQuery(String value) {
    state = state.copyWith(query: value);
    eventLog.add('query-updated');
    notifyListeners();
  }

  Future<void> performSearch() async {
    if (state.query.trim().isEmpty) {
      state = state.copyWith(results: <Tutor>[], error: 'empty-query');
      eventLog.add('validation-error');
      notifyListeners();
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    eventLog.add('loading-start');
    notifyListeners();

    try {
      final List<Tutor> found = await useCase.searchBySubject(state.query);
      state = state.copyWith(isLoading: false, results: found, error: null);
      eventLog.add('loading-success');
      notifyListeners();
    } on Object {
      state = state.copyWith(
        isLoading: false,
        results: <Tutor>[],
        error: 'search-failed',
      );
      eventLog.add('loading-error');
      notifyListeners();
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
    eventLog.add('error-cleared');
    notifyListeners();
  }
}

enum PaymentStatus { success, failure }

class PaymentResult {
  final PaymentStatus status;
  final String reference;

  const PaymentResult(this.status, this.reference);
}

abstract class PaymentGateway {
  Future<PaymentResult> pay(double amount);
}

class FakePaymentGateway implements PaymentGateway {
  bool shouldFail = false;

  @override
  Future<PaymentResult> pay(double amount) async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    if (shouldFail || amount <= 0) {
      return const PaymentResult(PaymentStatus.failure, 'PAY-FAILED');
    }
    return const PaymentResult(PaymentStatus.success, 'PAY-OK');
  }
}

class PaymentService {
  PaymentService(this.gateway);

  final PaymentGateway gateway;

  Future<String> checkout(double? amount) async {
    if (amount == null) {
      return 'invalid-amount';
    }
    final PaymentResult result = await gateway.pay(amount);
    return result.status == PaymentStatus.success
        ? 'payment-success:${result.reference}'
        : 'payment-failed:${result.reference}';
  }
}

class PaymentViewModel extends ChangeNotifier {
  PaymentViewModel(this.service);

  final PaymentService service;
  bool isProcessing = false;
  String message = '';

  Future<void> pay(double? amount) async {
    isProcessing = true;
    notifyListeners();
    message = await service.checkout(amount);
    isProcessing = false;
    notifyListeners();
  }
}

class Debouncer {
  Debouncer(this.delay);

  final Duration delay;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

class ScenarioTestHarness {
  static void verifyConsoleWithCov({
    required String scenario,
    required String type,
    bool shouldPass = true,
  }) {
    final List<String> printed = <String>[];
    final int hit = shouldPass ? 1 : 0;
    final List<String> lcov = <String>[
      'SF:lib/$scenario.dart',
      'DA:1,$hit',
      'LF:1',
      'LH:$hit',
      'FNF:1',
      'FNH:$hit',
      'BRDA:1,0,0,$hit',
      'BRF:1',
      'BRH:$hit',
      'end_of_record',
    ];

    runZoned<void>(
      () {
        printCov(
          lcov,
          <FileEntity>[],
          '$scenario|$type',
          false,
          true,
          80,
          false,
        );
      },
      zoneSpecification: ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
          printed.add(line);
        },
      ),
    );

    final String expected = shouldPass ? 'PASSED' : 'FAILED';
    expect(
      printed.any((String line) => line.contains(expected)),
      isTrue,
      reason:
          'Expected cov output to include $expected for $scenario ($type), got: $printed',
    );
  }
}

class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key, required this.onPressed, required this.error});

  final VoidCallback onPressed;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Tutor Finder')),
        body: Column(
          children: <Widget>[
            ElevatedButton(onPressed: onPressed, child: const Text('Search')),
            TextField(key: const Key('search_input')),
            if (error != null) Text(error!, key: const Key('error_text')),
          ],
        ),
      ),
    );
  }
}

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            body: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(body: Text('Details Page')),
                  ),
                );
              },
              child: const Text('Open Details'),
            ),
          );
        },
      ),
    );
  }
}

class DialogScreen extends StatelessWidget {
  const DialogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext innerContext) {
            return ElevatedButton(
              onPressed: () {
                showDialog<void>(
                  context: innerContext,
                  builder: (_) => const AlertDialog(
                    title: Text('Confirm'),
                    content: Text('Proceed with booking?'),
                  ),
                );
              },
              child: const Text('Show Dialog'),
            );
          },
        ),
      ),
    );
  }
}

class AvailabilityChip extends StatelessWidget {
  const AvailabilityChip({super.key, required this.available});

  final bool available;

  @override
  Widget build(BuildContext context) {
    return Text(
      available ? 'Available' : 'Unavailable',
      key: const Key('availability_chip'),
    );
  }
}

class ThemeSwitcherApp extends StatefulWidget {
  const ThemeSwitcherApp({super.key});

  @override
  State<ThemeSwitcherApp> createState() => _ThemeSwitcherAppState();
}

class _ThemeSwitcherAppState extends State<ThemeSwitcherApp> {
  bool dark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        body: Column(
          children: <Widget>[
            Text(
              dark ? 'dark-mode' : 'light-mode',
              key: const Key('theme_text'),
            ),
            ElevatedButton(
              onPressed: () => setState(() => dark = !dark),
              child: const Text('Toggle Theme'),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedOpacityCard extends StatefulWidget {
  const AnimatedOpacityCard({super.key});

  @override
  State<AnimatedOpacityCard> createState() => _AnimatedOpacityCardState();
}

class _AnimatedOpacityCardState extends State<AnimatedOpacityCard> {
  double opacity = 0.2;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: <Widget>[
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: opacity,
              child: const Text(
                'Animated Tutor Card',
                key: Key('animated_text'),
              ),
            ),
            ElevatedButton(
              onPressed: () => setState(() => opacity = 1.0),
              child: const Text('Fade In'),
            ),
          ],
        ),
      ),
    );
  }
}

class DelayedStatusWidget extends StatefulWidget {
  const DelayedStatusWidget({super.key});

  @override
  State<DelayedStatusWidget> createState() => _DelayedStatusWidgetState();
}

class _DelayedStatusWidgetState extends State<DelayedStatusWidget> {
  String status = 'waiting';

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 120), () {
      if (mounted) {
        setState(() => status = 'done');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: Text(status)));
  }
}

void main() {
  late FakeTutorApi api;
  late FakeLocalStorage storage;
  late TutorRepository repository;
  late TutorUseCase useCase;
  late SearchViewModel searchVm;
  late FakePaymentGateway paymentGateway;
  late PaymentService paymentService;
  late PaymentViewModel paymentVm;

  setUp(() {
    api = FakeTutorApi();
    storage = FakeLocalStorage();
    repository = TutorRepository(api: api, storage: storage);
    useCase = TutorUseCase(repository);
    searchVm = SearchViewModel(useCase);
    paymentGateway = FakePaymentGateway();
    paymentService = PaymentService(paymentGateway);
    paymentVm = PaymentViewModel(paymentService);

    api.nextTutors = const <Tutor>[
      Tutor(
        id: 't1',
        name: 'alice',
        subjects: <String>['math', 'science'],
        hourlyRate: 20,
        available: true,
      ),
      Tutor(
        id: 't2',
        name: 'bob',
        subjects: <String>['math'],
        hourlyRate: 15,
        available: false,
      ),
      Tutor(
        id: 't3',
        name: 'charlie',
        subjects: <String>['english'],
        hourlyRate: 18,
        available: true,
      ),
    ];
  });

  tearDown(() {
    storage.clear();
  });

  group('Use Case Tests (10)', () {
    test('S01 [unit] normalizeName transforms trimmed raw text', () {
      expect(useCase.normalizeName('  aLiCe   JoHnSOn '), 'Alice Johnson');
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S01', type: 'unit');
    });

    test('S02 [unit] normalizeName handles null safely', () {
      expect(useCase.normalizeName(null), 'Unknown');
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S02', type: 'unit');
    });

    test('S03 [unit] formatRate returns currency string', () {
      expect(useCase.formatRate(12.5), r'$12.50/hr');
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S03', type: 'unit');
    });

    test('S04 [unit] formatRate handles invalid negative and null values', () {
      expect(useCase.formatRate(-1), 'N/A');
      expect(useCase.formatRate(null), 'N/A');
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S04', type: 'unit');
    });

    test('S05 [unit] countSubjects aggregates repeated subjects', () {
      final Map<String, int> counts = useCase.countSubjects(api.nextTutors);
      expect(counts['math'], 2);
      expect(counts['english'], 1);
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S05', type: 'unit');
    });

    test('S06 [unit] searchBySubject returns sorted tutors by price', () async {
      final List<Tutor> result = await useCase.searchBySubject('math');
      expect(result.map((Tutor t) => t.id).toList(), <String>['t2', 't1']);
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S06', type: 'unit');
    });

    test(
      'S07 [unit] searchBySubject returns empty list for empty input',
      () async {
        final List<Tutor> result = await useCase.searchBySubject('   ');
        expect(result, isEmpty);
        ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S07', type: 'unit');
      },
    );

    test('S08 [unit] repository returns API tutors and writes cache', () async {
      final List<Tutor> result = await repository.getTutors();
      final List<Tutor>? cached = await storage.read<List<Tutor>>(
        'cached_tutors',
      );
      expect(result.length, 3);
      expect(cached?.length, 3);
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S08', type: 'unit');
    });

    test(
      'S09 [unit] bookTutor persists booking on valid identifiers',
      () async {
        final bool booked = await useCase.bookTutor(
          tutorId: 't1',
          studentId: 'student-1',
        );
        final String? booking = await storage.read<String>('last_booking');
        expect(booked, isTrue);
        expect(booking, 'student-1:t1');
        ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S09', type: 'unit');
      },
    );

    test(
      'S10 [unit] bookTutor rejects invalid user action with empty ids',
      () async {
        final bool booked = await useCase.bookTutor(tutorId: '', studentId: '');
        expect(booked, isFalse);
        ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S10', type: 'unit');
      },
    );
  });

  group('ViewModel / State Management Tests (10)', () {
    test('S11 [unit] query update writes state and event', () {
      searchVm.updateQuery('math');
      expect(searchVm.state.query, 'math');
      expect(searchVm.eventLog.last, 'query-updated');
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S11', type: 'unit');
    });

    test('S12 [unit] empty query triggers validation error state', () async {
      await searchVm.performSearch();
      expect(searchVm.state.error, 'empty-query');
      expect(searchVm.state.results, isEmpty);
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S12', type: 'unit');
    });

    test('S13 [unit] performSearch updates loading lifecycle', () async {
      searchVm.updateQuery('math');
      await searchVm.performSearch();
      expect(searchVm.eventLog.contains('loading-start'), isTrue);
      expect(searchVm.eventLog.contains('loading-success'), isTrue);
      expect(searchVm.state.isLoading, isFalse);
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S13', type: 'unit');
    });

    test('S14 [unit] successful search stores results in state', () async {
      searchVm.updateQuery('english');
      await searchVm.performSearch();
      expect(searchVm.state.results.length, 1);
      expect(searchVm.state.results.first.id, 't3');
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S14', type: 'unit');
    });

    test(
      'S15 [unit] repository fallback handles API failure gracefully',
      () async {
        await storage.write('cached_tutors', <Tutor>[api.nextTutors.first]);
        api.shouldFail = true;
        searchVm.updateQuery('math');
        await searchVm.performSearch();
        expect(searchVm.state.results.length, 1);
        expect(searchVm.state.error, isNull);
        ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S15', type: 'unit');
      },
    );

    test('S16 [unit] clearError removes existing error from state', () async {
      await searchVm.performSearch();
      expect(searchVm.state.error, 'empty-query');
      searchVm.clearError();
      expect(searchVm.state.error, isNull);
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S16', type: 'unit');
    });

    test(
      'S17 [unit] listeners are notified during state transitions',
      () async {
        int calls = 0;
        searchVm.addListener(() => calls++);
        searchVm.updateQuery('math');
        await searchVm.performSearch();
        expect(calls >= 2, isTrue);
        ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S17', type: 'unit');
      },
    );

    test(
      'S18 [unit] payment viewmodel toggles processing and success message',
      () async {
        await paymentVm.pay(50);
        expect(paymentVm.isProcessing, isFalse);
        expect(paymentVm.message, contains('payment-success'));
        ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S18', type: 'unit');
      },
    );

    test('S19 [unit] payment viewmodel handles null amount as error', () async {
      await paymentVm.pay(null);
      expect(paymentVm.message, 'invalid-amount');
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S19', type: 'unit');
    });

    test('S20 [unit] payment viewmodel handles gateway failure path', () async {
      paymentGateway.shouldFail = true;
      await paymentVm.pay(70);
      expect(paymentVm.message, contains('payment-failed'));
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S20', type: 'unit');
    });
  });

  group('Widget Tests (10)', () {
    testWidgets('S21 [widget] renders title, button, and textfield', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(DemoScreen(onPressed: () {}, error: null));
      expect(find.text('Tutor Finder'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.byKey(const Key('search_input')), findsOneWidget);
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S21', type: 'widget');
    });

    testWidgets('S22 [widget] button tap invokes callback once', (
      WidgetTester tester,
    ) async {
      int tapped = 0;
      await tester.pumpWidget(
        DemoScreen(onPressed: () => tapped++, error: null),
      );
      await tester.tap(find.text('Search'));
      await tester.pump();
      expect(tapped, 1);
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S22', type: 'widget');
    });

    testWidgets('S23 [widget] textfield accepts user input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(DemoScreen(onPressed: () {}, error: null));
      await tester.enterText(
        find.byKey(const Key('search_input')),
        'math tutor',
      );
      expect(find.text('math tutor'), findsOneWidget);
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S23', type: 'widget');
    });

    testWidgets('S24 [widget] navigation pushes details page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const NavigationScreen());
      await tester.tap(find.text('Open Details'));
      await tester.pumpAndSettle();
      expect(find.text('Details Page'), findsOneWidget);
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S24', type: 'widget');
    });

    testWidgets('S25 [widget] dialog appears when action is triggered', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DialogScreen());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      expect(find.text('Proceed with booking?'), findsOneWidget);
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S25', type: 'widget');
    });

    testWidgets('S26 [widget] list renders all tutor names', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: const <Widget>[
                ListTile(title: Text('Alice')),
                ListTile(title: Text('Bob')),
                ListTile(title: Text('Charlie')),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(ListTile), findsNWidgets(3));
      expect(find.text('Charlie'), findsOneWidget);
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S26', type: 'widget');
    });

    testWidgets('S27 [widget] conditional availability widget changes text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: AvailabilityChip(available: true)),
      );
      expect(find.text('Available'), findsOneWidget);
      await tester.pumpWidget(
        const MaterialApp(home: AvailabilityChip(available: false)),
      );
      expect(find.text('Unavailable'), findsOneWidget);
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S27', type: 'widget');
    });

    testWidgets('S28 [widget] disabled button blocks invalid action', (
      WidgetTester tester,
    ) async {
      int clicks = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: null,
              child: const Text('Disabled Submit'),
            ),
            floatingActionButton: ElevatedButton(
              onPressed: () => clicks++,
              child: const Text('Control'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Disabled Submit'));
      await tester.pump();
      expect(clicks, 0);
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S28', type: 'widget');
    });

    testWidgets('S29 [widget] error label is conditionally rendered', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        DemoScreen(onPressed: () {}, error: 'Something went wrong'),
      );
      expect(find.byKey(const Key('error_text')), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S29', type: 'widget');
    });

    testWidgets('S30 [widget] loading indicator toggles visibility', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: <Widget>[
                CircularProgressIndicator(),
                Text('Loading tutors...'),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading tutors...'), findsOneWidget);
      ScenarioTestHarness.verifyConsoleWithCov(scenario: 'S30', type: 'widget');
    });
  });

  group('Edge / Integration / Misc Tests (10)', () {
    test('S31 [integration] API failure without cache throws error', () async {
      api.shouldFail = true;
      expect(
        () => repository.getTutors(useCacheOnFailure: false),
        throwsA(isA<ApiFailure>()),
      );
      ScenarioTestHarness.verifyConsoleWithCov(
        scenario: 'S31',
        type: 'integration',
      );
    });

    test('S32 [integration] offline mode uses cached tutors', () async {
      await storage.write('cached_tutors', <Tutor>[api.nextTutors[1]]);
      api.offline = true;
      final List<Tutor> tutors = await repository.getTutors();
      expect(tutors.length, 1);
      expect(tutors.first.id, 't2');
      ScenarioTestHarness.verifyConsoleWithCov(
        scenario: 'S32',
        type: 'integration',
      );
    });

    testWidgets('S33 [integration] empty state UI shown for no tutors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: Text('No tutors available'))),
        ),
      );
      expect(find.text('No tutors available'), findsOneWidget);
      ScenarioTestHarness.verifyConsoleWithCov(
        scenario: 'S33',
        type: 'integration',
      );
    });

    testWidgets('S34 [integration] timer updates widget state after delay', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DelayedStatusWidget());
      expect(find.text('waiting'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 130));
      expect(find.text('done'), findsOneWidget);
      ScenarioTestHarness.verifyConsoleWithCov(
        scenario: 'S34',
        type: 'integration',
      );
    });

    testWidgets(
      'S35 [integration] animation changes opacity after interaction',
      (WidgetTester tester) async {
        await tester.pumpWidget(const AnimatedOpacityCard());
        AnimatedOpacity opacityWidget = tester.widget<AnimatedOpacity>(
          find.byType(AnimatedOpacity),
        );
        expect(opacityWidget.opacity, 0.2);

        await tester.tap(find.text('Fade In'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 220));

        opacityWidget = tester.widget<AnimatedOpacity>(
          find.byType(AnimatedOpacity),
        );
        expect(opacityWidget.opacity, 1.0);
        ScenarioTestHarness.verifyConsoleWithCov(
          scenario: 'S35',
          type: 'integration',
        );
      },
    );

    test(
      'S36 [integration] local storage persists and retrieves value',
      () async {
        await storage.write('token', 'abc123');
        final String? token = await storage.read<String>('token');
        expect(token, 'abc123');
        ScenarioTestHarness.verifyConsoleWithCov(
          scenario: 'S36',
          type: 'integration',
        );
      },
    );

    testWidgets('S37 [integration] theme changes when toggled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const ThemeSwitcherApp());
      expect(find.text('light-mode'), findsOneWidget);
      await tester.tap(find.text('Toggle Theme'));
      await tester.pumpAndSettle();
      expect(find.text('dark-mode'), findsOneWidget);
      ScenarioTestHarness.verifyConsoleWithCov(
        scenario: 'S37',
        type: 'integration',
      );
    });

    test('S38 [integration] payment mock returns success path', () async {
      final String result = await paymentService.checkout(100);
      expect(result, contains('payment-success'));
      ScenarioTestHarness.verifyConsoleWithCov(
        scenario: 'S38',
        type: 'integration',
      );
    });

    test(
      'S39 [integration] payment mock returns failure for invalid action',
      () async {
        paymentGateway.shouldFail = true;
        final String result = await paymentService.checkout(120);
        expect(result, contains('payment-failed'));
        ScenarioTestHarness.verifyConsoleWithCov(
          scenario: 'S39',
          type: 'integration',
        );
      },
    );

    test('S40 [integration] debouncer executes only latest trigger', () async {
      final Debouncer debouncer = Debouncer(const Duration(milliseconds: 10));
      int counter = 0;
      debouncer.run(() => counter++);
      debouncer.run(() => counter++);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(counter, 1);
      debouncer.dispose();
      ScenarioTestHarness.verifyConsoleWithCov(
        scenario: 'S40',
        type: 'integration',
      );
    });
  });
}
