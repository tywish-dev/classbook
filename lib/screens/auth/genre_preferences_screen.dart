import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../models/genre.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_button.dart';
import '../home_screen.dart';

class GenrePreferencesScreen extends StatefulWidget {
  const GenrePreferencesScreen({super.key});

  @override
  State<GenrePreferencesScreen> createState() => _GenrePreferencesScreenState();
}

class _GenrePreferencesScreenState extends State<GenrePreferencesScreen> {
  final List<Genre> _allGenres = [
    Genre(
      id: '1',
      name: 'Romantik',
      iconPath: 'assets/icons/genres/romance.png',
    ),
    Genre(id: '2', name: 'Gizem', iconPath: 'assets/icons/genres/mystery.png'),
    Genre(
      id: '3',
      name: 'Bilim Kurgu',
      iconPath: 'assets/icons/genres/scifi.png',
    ),
    Genre(
      id: '4',
      name: 'Fantastik',
      iconPath: 'assets/icons/genres/fantasy.png',
    ),
    Genre(id: '5', name: 'Korku', iconPath: 'assets/icons/genres/horror.png'),
    Genre(
      id: '6',
      name: 'Gerilim',
      iconPath: 'assets/icons/genres/thriller.png',
    ),
    Genre(
      id: '7',
      name: 'Tarih',
      iconPath: 'assets/icons/genres/historical.png',
    ),
    Genre(
      id: '8',
      name: 'Genç Yetişkin',
      iconPath: 'assets/icons/genres/ya.png',
    ),
    Genre(
      id: '9',
      name: 'Biyografi',
      iconPath: 'assets/icons/genres/biography.png',
    ),
  ];

  final Set<String> _selectedGenreIds = {};
  bool _isLoading = false;

  void _toggleGenre(String genreId) {
    setState(() {
      if (_selectedGenreIds.contains(genreId)) {
        _selectedGenreIds.remove(genreId);
      } else {
        _selectedGenreIds.add(genreId);
      }
    });
  }

  void _handleContinue() async {
    if (_selectedGenreIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen en az bir tür seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.saveGenrePreferences(
        _selectedGenreIds.toList(),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Navigate to home screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false, // Remove all previous routes
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bir hata oluştu: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
              child: Text(
                'Hangi türleri seversiniz?',
                style: AppTextStyles.heading1.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Okuma deneyiminizi kişiselleştirmek için favori türlerinizi seçin',
                style: AppTextStyles.body.copyWith(color: AppColors.textGrey),
              ),
            ),

            const SizedBox(height: 32),

            // Genres grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _allGenres.length,
                  itemBuilder: (context, index) {
                    final genre = _allGenres[index];
                    final isSelected = _selectedGenreIds.contains(genre.id);

                    return GestureDetector(
                      onTap: () => _toggleGenre(genre.id),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.primaryGreen.withOpacity(0.3)
                                      : Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.primaryGreen
                                        : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.book,
                              color:
                                  isSelected
                                      ? AppColors.primaryGreen
                                      : AppColors.textGrey,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            genre.name,
                            style: AppTextStyles.caption.copyWith(
                              color:
                                  isSelected
                                      ? AppColors.primaryGreen
                                      : AppColors.textWhite,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(24),
              child: AuthButton(
                text: 'Devam Et',
                onPressed: _handleContinue,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
