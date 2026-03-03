import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/study_resource_entity.dart';
import '../providers/study_providers.dart';
import '../utils/study_resource_launcher.dart';

class StudyResourcesPage extends ConsumerStatefulWidget {
  const StudyResourcesPage({super.key});

  @override
  ConsumerState<StudyResourcesPage> createState() => _StudyResourcesPageState();
}

class _StudyResourcesPageState extends ConsumerState<StudyResourcesPage> {
  String? _selectedCategory;
  static const String _advancedReactPatternsTitle = 'advanced react patterns';

  static final List<StudyResourceEntity> _nextJsLibraryDefaults = [
    _defaultResource(
      id: 'default-math-1',
      title: 'Algebra Fundamentals',
      category: 'Math',
      url: 'https://www.khanacademy.org/math/algebra',
      duration: '40+ lessons',
      tutorName: 'Khan Academy',
    ),
    _defaultResource(
      id: 'default-math-2',
      title: 'Calculus I – Limits & Derivatives',
      category: 'Math',
      url:
          'https://ocw.mit.edu/courses/18-01sc-single-variable-calculus-fall-2010/',
      duration: 'Full course',
      tutorName: 'MIT OCW',
    ),
    _defaultResource(
      id: 'default-math-3',
      title: 'Geometry – Shapes, Angles & Proofs',
      category: 'Math',
      url: 'https://www.khanacademy.org/math/geometry',
      duration: '30+ lessons',
      tutorName: 'Khan Academy',
    ),
    _defaultResource(
      id: 'default-math-4',
      title: 'Statistics & Probability Essentials',
      category: 'Math',
      url: 'https://www.khanacademy.org/math/statistics-probability',
      duration: '50+ lessons',
      tutorName: 'Khan Academy',
    ),
    _defaultResource(
      id: 'default-math-5',
      title: 'Linear Algebra – Vectors & Matrices',
      category: 'Math',
      url: 'https://ocw.mit.edu/courses/18-06sc-linear-algebra-fall-2011/',
      duration: 'Full course',
      tutorName: 'MIT OCW',
    ),
    _defaultResource(
      id: 'default-math-6',
      title: 'Trigonometry – Functions & Identities',
      category: 'Math',
      url: 'https://www.khanacademy.org/math/trigonometry',
      duration: '25+ lessons',
      tutorName: 'Khan Academy',
    ),
    _defaultResource(
      id: 'default-sci-1',
      title: 'Physics – Mechanics & Motion',
      category: 'Science',
      url: 'https://www.khanacademy.org/science/physics',
      duration: '60+ lessons',
      tutorName: 'Khan Academy',
    ),
    _defaultResource(
      id: 'default-sci-2',
      title: 'Chemistry – Atoms, Bonding & Reactions',
      category: 'Science',
      url: 'https://www.khanacademy.org/science/chemistry',
      duration: '45+ lessons',
      tutorName: 'Khan Academy',
    ),
    _defaultResource(
      id: 'default-sci-3',
      title: 'Biology – Cells, Genetics & Evolution',
      category: 'Science',
      url: 'https://www.khanacademy.org/science/biology',
      duration: '70+ lessons',
      tutorName: 'Khan Academy',
    ),
    _defaultResource(
      id: 'default-sci-4',
      title: 'Introduction to Astronomy',
      category: 'Science',
      url:
          'https://ocw.mit.edu/courses/8-282j-introduction-to-astronomy-spring-2006/',
      duration: 'Full course',
      tutorName: 'MIT OCW',
    ),
    _defaultResource(
      id: 'default-sci-5',
      title: 'Environmental Science & Ecology',
      category: 'Science',
      url: 'https://www.khanacademy.org/science/ap-biology/ecology-ap',
      duration: '20+ lessons',
      tutorName: 'Khan Academy',
    ),
    _defaultResource(
      id: 'default-sci-6',
      title: 'Organic Chemistry Fundamentals',
      category: 'Science',
      url: 'https://www.khanacademy.org/science/organic-chemistry',
      duration: '35+ lessons',
      tutorName: 'Khan Academy',
    ),
    _defaultResource(
      id: 'default-lang-1',
      title: 'English Grammar & Composition',
      category: 'Language',
      url: 'https://www.khanacademy.org/humanities/grammar',
      duration: '35+ lessons',
      tutorName: 'Khan Academy',
    ),
    _defaultResource(
      id: 'default-lang-2',
      title: 'Creative Writing Workshop',
      category: 'Language',
      url:
          'https://ocw.mit.edu/courses/21w-750-writing-and-reading-the-essay-fall-2016/',
      duration: 'Full course',
      tutorName: 'MIT OCW',
    ),
    _defaultResource(
      id: 'default-lang-3',
      title: 'Urdu Language – Reading & Writing',
      category: 'Language',
      url: 'https://www.rekhta.org/',
      duration: 'Self-paced',
      tutorName: 'Rekhta',
    ),
    _defaultResource(
      id: 'default-lang-4',
      title: 'Vocabulary Builder – Word Power',
      category: 'Language',
      url: 'https://www.vocabulary.com/',
      duration: 'Self-paced',
      tutorName: 'Vocabulary.com',
    ),
    _defaultResource(
      id: 'default-lang-5',
      title: 'Public Speaking & Presentation Skills',
      category: 'Language',
      url: 'https://ocw.mit.edu/courses/21w-747-2-rhetoric-spring-2006/',
      duration: 'Full course',
      tutorName: 'MIT OCW',
    ),
    _defaultResource(
      id: 'default-lang-6',
      title: 'Essay Writing & Critical Reading',
      category: 'Language',
      url: 'https://www.khanacademy.org/ela',
      duration: '30+ lessons',
      tutorName: 'Khan Academy',
    ),
    _defaultResource(
      id: 'default-cs-1',
      title: 'Intro to Programming (Python)',
      category: 'Computer',
      url:
          'https://ocw.mit.edu/courses/6-0001-introduction-to-computer-science-and-programming-in-python-fall-2016/',
      duration: 'Full course',
      tutorName: 'MIT OCW',
    ),
    _defaultResource(
      id: 'default-cs-2',
      title: 'Web Development – HTML, CSS & JS',
      category: 'Computer',
      url: 'https://www.freecodecamp.org/learn/responsive-web-design/',
      duration: '300 hours',
      tutorName: 'freeCodeCamp',
    ),
    _defaultResource(
      id: 'default-cs-3',
      title: 'Data Structures & Algorithms',
      category: 'Computer',
      url: 'https://www.khanacademy.org/computing/computer-science/algorithms',
      duration: '40+ lessons',
      tutorName: 'Khan Academy',
    ),
    _defaultResource(
      id: 'default-cs-4',
      title: 'JavaScript Algorithms & Projects',
      category: 'Computer',
      url:
          'https://www.freecodecamp.org/learn/javascript-algorithms-and-data-structures/',
      duration: '300 hours',
      tutorName: 'freeCodeCamp',
    ),
    _defaultResource(
      id: 'default-cs-5',
      title: 'Database Design & SQL Basics',
      category: 'Computer',
      url: 'https://www.khanacademy.org/computing/computer-programming/sql',
      duration: '20+ lessons',
      tutorName: 'Khan Academy',
    ),
    _defaultResource(
      id: 'default-cs-6',
      title: 'Cybersecurity Fundamentals',
      category: 'Computer',
      url:
          'https://ocw.mit.edu/courses/6-858-computer-systems-security-fall-2014/',
      duration: 'Full course',
      tutorName: 'MIT OCW',
    ),
    _defaultResource(
      id: 'default-hist-1',
      title: 'World History – Ancient Civilizations',
      category: 'History',
      url: 'https://www.khanacademy.org/humanities/world-history',
      duration: '80+ lessons',
      tutorName: 'Khan Academy',
    ),
    _defaultResource(
      id: 'default-hist-2',
      title: 'History of Science & Technology',
      category: 'History',
      url:
          'https://ocw.mit.edu/courses/sts-050-the-history-of-mit-spring-2016/',
      duration: 'Full course',
      tutorName: 'MIT OCW',
    ),
    _defaultResource(
      id: 'default-hist-3',
      title: 'Islamic Golden Age & Mughal Empire',
      category: 'History',
      url:
          'https://www.khanacademy.org/humanities/world-history/medieval-times',
      duration: '25+ lessons',
      tutorName: 'Khan Academy',
    ),
    _defaultResource(
      id: 'default-hist-4',
      title: 'Modern World History – 1900 to Present',
      category: 'History',
      url: 'https://www.khanacademy.org/humanities/whp-origins',
      duration: '50+ lessons',
      tutorName: 'Khan Academy',
    ),
    _defaultResource(
      id: 'default-hist-5',
      title: 'Ancient Greece & Rome',
      category: 'History',
      url:
          'https://www.khanacademy.org/humanities/world-history/ancient-medieval',
      duration: '40+ lessons',
      tutorName: 'Khan Academy',
    ),
    _defaultResource(
      id: 'default-hist-6',
      title: 'History of Pakistan – Independence to Today',
      category: 'History',
      url: 'https://www.khanacademy.org/humanities/world-history/euro-hist',
      duration: '20+ lessons',
      tutorName: 'Khan Academy',
    ),
  ];

  static StudyResourceEntity _defaultResource({
    required String id,
    required String title,
    required String category,
    required String url,
    required String duration,
    required String tutorName,
  }) {
    final defaultCreatedAt = DateTime(2026, 1, 1);
    return StudyResourceEntity(
      id: id,
      title: title,
      category: category,
      type: 'MODULE',
      url: url,
      duration: duration,
      tutorId: '',
      tutorName: tutorName,
      isPublic: true,
      createdAt: defaultCreatedAt,
      updatedAt: defaultCreatedAt,
    );
  }

  static final RegExp _fileExtensionPattern = RegExp(
    r'\.(pdf|doc|docx|ppt|pptx|txt|zip|jpg|jpeg|png|gif|mp4|mov|avi|webm|mkv)(\?.*)?$',
    caseSensitive: false,
  );

  bool _isPdfResource(StudyResourceEntity resource) {
    final url = resource.url.trim();
    return resource.type.toUpperCase() == 'PDF' ||
        RegExp(r'\.pdf(\?.*)?$', caseSensitive: false).hasMatch(url);
  }

  bool _isModuleResource(StudyResourceEntity resource) {
    return resource.type.toUpperCase() == 'MODULE';
  }

  String _normalizeTitle(String title) {
    return title.trim().toLowerCase();
  }

  bool _isAdvancedReactPatterns(StudyResourceEntity resource) {
    return _normalizeTitle(resource.title) == _advancedReactPatternsTitle;
  }

  bool _isExternalLinkResource(StudyResourceEntity resource) {
    final url = resource.url.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return false;
    }

    return !_fileExtensionPattern.hasMatch(url);
  }

  List<StudyResourceEntity> _libraryResourcesOnly(
    List<StudyResourceEntity> resources,
  ) {
    return resources.where((resource) {
      final isAllowedPdf =
          _isPdfResource(resource) && _isAdvancedReactPatterns(resource);
      return isAllowedPdf ||
          _isModuleResource(resource) ||
          _isExternalLinkResource(resource);
    }).toList();
  }

  List<StudyResourceEntity> _mergeWithNextLibraryDefaults(
    List<StudyResourceEntity> backendResources,
  ) {
    final filteredBackendResources = _libraryResourcesOnly(backendResources);
    final normalizedBackendTitles = filteredBackendResources
        .map((resource) => _normalizeTitle(resource.title))
        .toSet();

    final defaultsForCategory = _selectedCategory == null
        ? _nextJsLibraryDefaults
        : _nextJsLibraryDefaults
              .where((resource) => resource.category == _selectedCategory)
              .toList();

    final filteredDefaults = defaultsForCategory
        .where(
          (resource) => !normalizedBackendTitles.contains(
            _normalizeTitle(resource.title),
          ),
        )
        .toList();

    return [...filteredBackendResources, ...filteredDefaults];
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(studyNotifierProvider.notifier).fetchResources(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studyState = ref.watch(studyNotifierProvider);
    final visibleResources = _mergeWithNextLibraryDefaults(
      studyState.resources,
    );

    // Extract unique categories
    final categories = visibleResources.map((r) => r.category).toSet().toList()
      ..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Study Resources')),
      body: Column(
        children: [
          // Category filter chips
          if (categories.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: _selectedCategory == null,
                      onSelected: (_) {
                        setState(() => _selectedCategory = null);
                        ref
                            .read(studyNotifierProvider.notifier)
                            .fetchResources();
                      },
                    ),
                  ),
                  ...categories.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat),
                        selected: _selectedCategory == cat,
                        onSelected: (_) {
                          setState(() => _selectedCategory = cat);
                          ref
                              .read(studyNotifierProvider.notifier)
                              .fetchResources(category: cat);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Resources list
          Expanded(
            child: studyState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : studyState.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          studyState.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(studyNotifierProvider.notifier)
                              .fetchResources(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : visibleResources.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.library_books,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No resources available',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => ref
                        .read(studyNotifierProvider.notifier)
                        .fetchResources(category: _selectedCategory),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: visibleResources.length,
                      itemBuilder: (context, index) {
                        return _ResourceCard(resource: visibleResources[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final StudyResourceEntity resource;

  const _ResourceCard({required this.resource});

  IconData _typeIcon() {
    switch (resource.type) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'MODULE':
        return Icons.school;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _typeColor() {
    switch (resource.type) {
      case 'PDF':
        return Colors.red;
      case 'MODULE':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _typeColor().withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_typeIcon(), color: _typeColor()),
        ),
        title: Text(
          resource.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    resource.category,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  resource.type,
                  style: TextStyle(
                    fontSize: 11,
                    color: _typeColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (resource.size != null || resource.duration != null) ...[
              const SizedBox(height: 4),
              Text(
                [
                  if (resource.size != null) resource.size!,
                  if (resource.duration != null) resource.duration!,
                ].join(' • '),
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
            if (resource.tutorName != null) ...[
              const SizedBox(height: 2),
              Text(
                'By ${resource.tutorName}',
                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.download, color: Colors.blue),
        onTap: () async {
          final opened = await StudyResourceLauncher.open(resource);
          if (!opened && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unable to open this study material.'),
              ),
            );
          }
        },
      ),
    );
  }
}
