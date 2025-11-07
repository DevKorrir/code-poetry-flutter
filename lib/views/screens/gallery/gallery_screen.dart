import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/gallery_viewmodel.dart';
import '../../../core/theme/text_styles.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GalleryViewModel>().loadPoems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GalleryViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Filter dialog
            },
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const LoadingIndicator()
          : viewModel.poems.isEmpty
          ? const EmptyState(
        title: 'No Poems Yet',
        message: 'Create your first poem to see it here!',
        icon: Icons.collections_outlined,
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: viewModel.poems.length,
        itemBuilder: (context, index) {
          final poem = viewModel.poems[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(poem.style),
              subtitle: Text(
                poem.poem.split('\n').first,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: poem.isFavorite
                  ? const Icon(Icons.favorite)
                  : null,
            ),
          );
        },
      ),
    );
  }
}