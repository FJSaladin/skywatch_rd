import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/observation_model.dart';

class ObservationCard extends StatelessWidget {
  final ObservationModel observation;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ObservationCard({
    super.key,
    required this.observation,
    required this.onTap,
    this.onDelete,
  });

  // Ícono según categoría
  IconData _categoryIcon(String categoria) {
    return switch (categoria) {
      'Astronomía'               => Icons.star_outlined,
      'Fenómeno atmosférico'     => Icons.cloud_outlined,
      'Aves migratorias'         => Icons.air,
      'Aeronave / Objeto artificial' => Icons.flight,
      'Fenómeno luminoso'        => Icons.lightbulb_outline,
      _                          => Icons.visibility_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final fecha = DateTime.tryParse(observation.fechaHora);
    final fechaStr = fecha != null
        ? DateFormat('dd MMM yyyy  HH:mm', 'es').format(fecha)
        : observation.fechaHora;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícono de categoría
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.nebulaPurple.withValues(alpha:0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _categoryIcon(observation.categoria),
                  color: AppTheme.starGold,
                ),
              ),
              const SizedBox(width: 14),

              // Título + info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      observation.titulo,
                      style: const TextStyle(
                        color:       AppTheme.moonWhite,
                        fontSize:    15,
                        fontWeight:  FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fechaStr,
                      style: const TextStyle(
                        color:    AppTheme.cosmicGrey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.label_outline,
                            size: 12, color: AppTheme.cosmicGrey),
                        const SizedBox(width: 4),
                        Text(
                          observation.categoria,
                          style: const TextStyle(
                            color:    AppTheme.cosmicGrey,
                            fontSize: 12,
                          ),
                        ),
                        if (observation.fotoPath != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.photo_camera_outlined,
                              size: 12, color: AppTheme.cosmicGrey),
                        ],
                        if (observation.audioPath != null) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.mic_outlined,
                              size: 12, color: AppTheme.cosmicGrey),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Botón eliminar
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppTheme.meteorRed, size: 20),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}