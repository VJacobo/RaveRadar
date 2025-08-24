import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/animal_model.dart';
import '../utils/constants.dart';

class AnimalsScreen extends StatefulWidget {
  const AnimalsScreen({super.key});

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  final _supabase = Supabase.instance.client;
  List<Animal> _animals = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAnimals();
  }

  Future<void> _fetchAnimals() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _supabase
          .from('animals')
          .select()
          .order('created_at', ascending: false);

      final animals = (response as List)
          .map((json) => Animal.fromJson(json))
          .toList();

      setState(() {
        _animals = animals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text(
          'Supabase Test',
          style: AppTextStyles.headline2,
        ),
        backgroundColor: AppColors.backgroundSecondary,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Error loading animals',
                style: AppTextStyles.headline3,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _error!,
                style: AppTextStyles.body2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: _fetchAnimals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.raveRegular,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                ),
                child: Text(
                  'Retry',
                  style: AppTextStyles.subtitle2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_animals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No animals found',
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _fetchAnimals,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.raveRegular,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
              child: Text(
                'Refresh',
                style: AppTextStyles.subtitle2,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchAnimals,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _animals.length,
        itemBuilder: (context, index) {
          final animal = _animals[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            color: AppColors.backgroundSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: animal.imageUrl != null
                    ? NetworkImage(animal.imageUrl!)
                    : null,
                backgroundColor: AppColors.raveRegular.withValues(alpha: 0.2),
                child: animal.imageUrl == null
                    ? Text(
                        animal.name[0].toUpperCase(),
                        style: AppTextStyles.headline3,
                      )
                    : null,
              ),
              title: Text(
                animal.name,
                style: AppTextStyles.headline3,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Species: ${animal.species}',
                    style: AppTextStyles.body2,
                  ),
                  if (animal.age != null)
                    Text(
                      'Age: ${animal.age} years',
                      style: AppTextStyles.caption,
                    ),
                  if (animal.description != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      animal.description!,
                      style: AppTextStyles.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${animal.name} selected'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}