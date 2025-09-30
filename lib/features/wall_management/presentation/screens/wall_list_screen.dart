import 'package:flutter/material.dart';
import '../../../../shared/domain/value_objects/location.dart';
import '../widgets/wall_list_view.dart';
import '../widgets/wall_filter_buttons.dart';
import '../widgets/recent_walls_slider.dart';

/// Screen displaying a list of walls with filtering and navigation capabilities
class WallListScreen extends StatefulWidget {
  final Location? userLocation;
  final Function(String wallId)? onWallSelected;

  const WallListScreen({
    super.key,
    this.userLocation,
    this.onWallSelected,
  });

  @override
  State<WallListScreen> createState() => _WallListScreenState();
}

class _WallListScreenState extends State<WallListScreen> {
  WallFilter _selectedFilter = WallFilter.nearby;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('담벼락 찾기'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              controller: _searchController,
              hintText: '담벼락 이름으로 검색...',
              leading: const Icon(Icons.search),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              trailing: _searchQuery.isNotEmpty
                  ? [
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Recent walls slider (when no search)
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 16),
            const RecentWallsSlider(),
            const SizedBox(height: 16),
          ],

          // Filter buttons
          WallFilterButtons(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),

          const SizedBox(height: 16),

          // Wall list
          Expanded(
            child: WallListView(
              filter: _selectedFilter,
              searchQuery: _searchQuery,
              userLocation: widget.userLocation,
              onWallSelected: widget.onWallSelected,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create wall screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('담벼락 생성 기능은 추후 구현 예정입니다')),
          );
        },
        child: const Icon(Icons.add_location),
        tooltip: '새 담벼락 만들기',
      ),
    );
  }
}

/// Filter options for wall list
enum WallFilter {
  nearby('근처'),
  recent('최근'),
  popular('인기'),
  visited('방문한'),
  all('전체');

  const WallFilter(this.displayName);
  final String displayName;
}