import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../observation_provider.dart';
import '../widgets/observation_card.dart';
import '../widgets/sky_empty_state.dart';
import 'observation_form_screen.dart';
import 'observation_detail_screen.dart';
import '../../profile/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Carga inicial — se ejecuta después del primer build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ObservationProvider>().loadObservations();
    });
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.deepBlue,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.meteorRed),
            SizedBox(width: 8),
            Text('Borrar Todo', style: TextStyle(color: AppTheme.moonWhite)),
          ],
        ),
        content: const Text(
          'Esta acción eliminará TODAS las observaciones y el perfil del dispositivo. No se puede deshacer.',
          style: TextStyle(color: AppTheme.cosmicGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.meteorRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await context.read<ObservationProvider>().deleteAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Todos los datos han sido eliminados'),
                    backgroundColor: AppTheme.auroraGreen,
                  ),
                );
              }
            },
            child: const Text('Borrar Todo'),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final provider = context.read<ObservationProvider>();
    showModalBottomSheet(
      context:           context,
      backgroundColor:   AppTheme.deepBlue,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filtrar por categoría',
                style: TextStyle(
                    color: AppTheme.moonWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Todas'),
                  selected: provider.filtroCategoria == null,
                  onSelected: (_) {
                    provider.clearFilters();
                    Navigator.pop(context);
                  },
                ),
                ...AppConstants.categorias.map((cat) => FilterChip(
                  label: Text(cat),
                  selected: provider.filtroCategoria == cat,
                  selectedColor: AppTheme.nebulaPurple,
                  onSelected: (_) {
                    provider.setFiltroCategoria(cat);
                    Navigator.pop(context);
                  },
                )),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ObservationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_outlined, color: AppTheme.starGold, size: 20),
            SizedBox(width: 8),
            Text('CieloObs',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          // Filtros
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: provider.hasActiveFilters
                  ? AppTheme.starGold
                  : AppTheme.moonWhite,
            ),
            tooltip: 'Filtrar',
            onPressed: () => _showFilterSheet(context),
          ),
          // Perfil
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Perfil',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          // Borrar todo
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined,
                color: AppTheme.meteorRed),
            tooltip: 'Borrar Todo',
            onPressed: () => _showDeleteAllDialog(context),
          ),
        ],
      ),

      body: switch (provider.state) {
        LoadingState.loading => const Center(
            child: CircularProgressIndicator(color: AppTheme.starGold)),
        LoadingState.error => Center(
            child: Text(provider.errorMessage ?? 'Error desconocido',
                style: const TextStyle(color: AppTheme.meteorRed))),
        _ => provider.observations.isEmpty
            ? const SkyEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: provider.observations.length,
                itemBuilder: (context, index) {
                  final obs = provider.observations[index];
                  return ObservationCard(
                    observation: obs,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ObservationDetailScreen(observation: obs),
                      ),
                    ),
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: AppTheme.deepBlue,
                          title: const Text('¿Eliminar observación?',
                              style: TextStyle(color: AppTheme.moonWhite)),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar')),
                            TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Eliminar',
                                    style: TextStyle(
                                        color: AppTheme.meteorRed))),
                          ],
                        ),
                      );
                      if (confirm == true && obs.id != null) {
                        await provider.deleteObservation(obs.id!);
                      }
                    },
                  );
                },
              ),
      },

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ObservationFormScreen()),
          );
          // Al regresar del formulario, recarga
          if (context.mounted) {
            context.read<ObservationProvider>().loadObservations();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva observación'),
      ),
    );
  }
}