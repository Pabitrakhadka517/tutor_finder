import 'package:flutter/material.dart';

import '../../domain/entities/tutor_search_params.dart';

/// Bottom sheet for filtering tutor search results.
/// Provides comprehensive filtering options including subjects, price, rating, etc.
class TutorFilterBottomSheet extends StatefulWidget {
  const TutorFilterBottomSheet({
    super.key,
    required this.onApplyFilters,
    this.initialParams,
  });

  final Function(TutorSearchParams) onApplyFilters;
  final TutorSearchParams? initialParams;

  @override
  State<TutorFilterBottomSheet> createState() => _TutorFilterBottomSheetState();
}

class _TutorFilterBottomSheetState extends State<TutorFilterBottomSheet> {
  late List<String> _selectedSubjects;
  late RangeValues _priceRange;
  late double _minRating;
  late int? _experienceYears;
  late bool _onlineOnly;
  late bool _inPersonOnly;
  late bool _verifiedOnly;
  late bool _availableOnly;
  late String? _location;
  late List<String> _languages;

  // Available options (would normally come from API or constants)
  static const List<String> _availableSubjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'Spanish',
    'French',
    'History',
    'Geography',
    'Computer Science',
    'Programming',
    'SAT Prep',
    'ACT Prep',
    'Music',
    'Art',
  ];

  static const List<String> _availableLanguages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Chinese',
    'Japanese',
    'Korean',
    'Arabic',
    'Russian',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  void _initializeFilters() {
    final params = widget.initialParams ?? const TutorSearchParams();

    _selectedSubjects = List.from(params.subjects);
    _priceRange = RangeValues(
      params.minPrice ?? 10.0,
      params.maxPrice ?? 100.0,
    );
    _minRating = params.minRating ?? 0.0;
    _experienceYears = params.minExperienceYears;
    _onlineOnly = params.onlineOnly;
    _inPersonOnly = params.inPersonOnly;
    _verifiedOnly = params.verifiedOnly;
    _availableOnly = params.availableOnly;
    _location = params.location;
    _languages = List.from(params.languages);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Filter Tutors'),
              actions: [
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
                TextButton(
                  onPressed: _applyFilters,
                  child: const Text('Apply'),
                ),
              ],
            ),
            body: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // Subjects
                _buildFilterSection(
                  title: 'Subjects',
                  child: _buildSubjectsFilter(),
                ),

                const SizedBox(height: 24),

                // Price range
                _buildFilterSection(
                  title:
                      'Price Range (\$${_priceRange.start.round()}/hr - \$${_priceRange.end.round()}/hr)',
                  child: _buildPriceRangeFilter(),
                ),

                const SizedBox(height: 24),

                // Minimum rating
                _buildFilterSection(
                  title:
                      'Minimum Rating (${_minRating.toStringAsFixed(1)} stars)',
                  child: _buildRatingFilter(),
                ),

                const SizedBox(height: 24),

                // Experience
                _buildFilterSection(
                  title: 'Minimum Experience',
                  child: _buildExperienceFilter(),
                ),

                const SizedBox(height: 24),

                // Location
                _buildFilterSection(
                  title: 'Location',
                  child: _buildLocationFilter(),
                ),

                const SizedBox(height: 24),

                // Languages
                _buildFilterSection(
                  title: 'Languages',
                  child: _buildLanguagesFilter(),
                ),

                const SizedBox(height: 24),

                // Boolean filters
                _buildFilterSection(
                  title: 'Additional Filters',
                  child: _buildBooleanFilters(),
                ),

                const SizedBox(height: 100), // Space for floating button
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildSubjectsFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableSubjects.map((subject) {
        final isSelected = _selectedSubjects.contains(subject);
        return FilterChip(
          label: Text(subject),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedSubjects.add(subject);
              } else {
                _selectedSubjects.remove(subject);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildPriceRangeFilter() {
    return RangeSlider(
      values: _priceRange,
      min: 5,
      max: 200,
      divisions: 39,
      labels: RangeLabels(
        '\$${_priceRange.start.round()}',
        '\$${_priceRange.end.round()}',
      ),
      onChanged: (values) {
        setState(() {
          _priceRange = values;
        });
      },
    );
  }

  Widget _buildRatingFilter() {
    return Slider(
      value: _minRating,
      min: 0,
      max: 5,
      divisions: 10,
      label: '${_minRating.toStringAsFixed(1)} stars',
      onChanged: (value) {
        setState(() {
          _minRating = value;
        });
      },
    );
  }

  Widget _buildExperienceFilter() {
    return DropdownButtonFormField<int?>(
      value: _experienceYears,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Select minimum experience',
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Any experience')),
        ...List.generate(10, (index) {
          final years = index + 1;
          return DropdownMenuItem(
            value: years,
            child: Text('${years}+ year${years > 1 ? 's' : ''}'),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _experienceYears = value;
        });
      },
    );
  }

  Widget _buildLocationFilter() {
    return TextFormField(
      initialValue: _location,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Enter city, state, or country',
        prefixIcon: Icon(Icons.location_on),
      ),
      onChanged: (value) {
        _location = value.isEmpty ? null : value;
      },
    );
  }

  Widget _buildLanguagesFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableLanguages.map((language) {
        final isSelected = _languages.contains(language);
        return FilterChip(
          label: Text(language),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _languages.add(language);
              } else {
                _languages.remove(language);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildBooleanFilters() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Online sessions only'),
          subtitle: const Text('Show only tutors who offer online lessons'),
          value: _onlineOnly,
          onChanged: (value) {
            setState(() {
              _onlineOnly = value ?? false;
              if (_onlineOnly) _inPersonOnly = false;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('In-person sessions only'),
          subtitle: const Text('Show only tutors who offer in-person lessons'),
          value: _inPersonOnly,
          onChanged: (value) {
            setState(() {
              _inPersonOnly = value ?? false;
              if (_inPersonOnly) _onlineOnly = false;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Verified tutors only'),
          subtitle: const Text('Show only verified tutors'),
          value: _verifiedOnly,
          onChanged: (value) {
            setState(() {
              _verifiedOnly = value ?? false;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Available now'),
          subtitle: const Text('Show only tutors with current availability'),
          value: _availableOnly,
          onChanged: (value) {
            setState(() {
              _availableOnly = value ?? false;
            });
          },
        ),
      ],
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedSubjects.clear();
      _priceRange = const RangeValues(10, 100);
      _minRating = 0.0;
      _experienceYears = null;
      _onlineOnly = false;
      _inPersonOnly = false;
      _verifiedOnly = false;
      _availableOnly = false;
      _location = null;
      _languages.clear();
    });
  }

  void _applyFilters() {
    final searchParams = TutorSearchParams(
      subjects: _selectedSubjects,
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      minRating: _minRating > 0 ? _minRating : null,
      minExperienceYears: _experienceYears,
      onlineOnly: _onlineOnly,
      inPersonOnly: _inPersonOnly,
      verifiedOnly: _verifiedOnly,
      availableOnly: _availableOnly,
      location: _location,
      languages: _languages,
    );

    widget.onApplyFilters(searchParams);
    Navigator.pop(context);
  }
}
