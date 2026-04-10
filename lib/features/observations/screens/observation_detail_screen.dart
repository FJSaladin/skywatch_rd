import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:skywatch_rd/features/observations/observation_provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/observation_model.dart';

class ObservationDetailScreen extends StatefulWidget {
  final ObservationModel observation;
  const ObservationDetailScreen({super.key, required this.observation});

  @override
  State<ObservationDetailScreen> createState() =>
      _ObservationDetailScreenState();
}

class _ObservationDetailScreenState extends State<ObservationDetailScreen> {
  final _audioPlayer = AudioPlayer();
  bool  _isPlaying   = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.play(
          DeviceFileSource(widget.observation.audioPath!));
      setState(() => _isPlaying = true);
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    }
  }

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.starGold),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppTheme.cosmicGrey, fontSize: 11)),
              Text(value,
                  style: const TextStyle(
                      color: AppTheme.moonWhite, fontSize: 14)),
            ],
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final obs   = widget.observation;
    final fecha = DateTime.tryParse(obs.fechaHora);
    final fechaStr = fecha != null
        ? DateFormat('dd MMMM yyyy, HH:mm', 'es').format(fecha)
        : obs.fechaHora;

    return Scaffold(
      appBar: AppBar(
        title: Text(obs.titulo),
        actions: [
          IconButton(
            icon:    const Icon(Icons.share_outlined),
            tooltip: 'Exportar JSON',
            onPressed: () =>
                context.read<ObservationProvider>().exportObservation(obs),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Foto ─────────────────────────────────────────
          if (obs.fotoPath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(obs.fotoPath!),
                height:  220,
                width:   double.infinity,
                fit:     BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          if (obs.fotoPath != null) const SizedBox(height: 16),

          // ── Info card ────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(Icons.schedule,  'Fecha y hora',  fechaStr),
                  _infoRow(Icons.label_outline, 'Categoría', obs.categoria),
                  _infoRow(Icons.cloud_outlined, 'Condiciones',
                      obs.condicionesCielo),
                  if (obs.duracionSeg != null)
                    _infoRow(Icons.timer_outlined, 'Duración',
                        '${obs.duracionSeg} segundos'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Descripción ──────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DESCRIPCIÓN',
                      style: TextStyle(
                          color:      AppTheme.starGold,
                          fontSize:   12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text(obs.descripcion,
                      style: const TextStyle(
                          color: AppTheme.moonWhite, height: 1.5)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Ubicación ────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('UBICACIÓN',
                      style: TextStyle(
                          color:      AppTheme.starGold,
                          fontSize:   12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  if (obs.ubicacionTexto != null)
                    _infoRow(Icons.place_outlined,
                        'Lugar', obs.ubicacionTexto!),
                  if (obs.lat != null && obs.lng != null) ...[
                    _infoRow(Icons.gps_fixed, 'Coordenadas',
                        '${obs.lat!.toStringAsFixed(5)}, '
                        '${obs.lng!.toStringAsFixed(5)}'),
                    const SizedBox(height: 8),
                    // Mapa
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 200,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter:
                                LatLng(obs.lat!, obs.lng!),
                            initialZoom: 14,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName:
                                  'com.tumatricula.cieloobs',
                            ),
                            MarkerLayer(markers: [
                              Marker(
                                point: LatLng(obs.lat!, obs.lng!),
                                child: const Icon(
                                  Icons.location_pin,
                                  color: AppTheme.meteorRed,
                                  size: 36,
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (obs.lat == null && obs.ubicacionTexto == null)
                    const Text('Sin ubicación registrada',
                        style: TextStyle(color: AppTheme.cosmicGrey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Audio ─────────────────────────────────────────
          if (obs.audioPath != null)
            Card(
              child: ListTile(
                leading: IconButton(
                  icon: Icon(
                    _isPlaying
                        ? Icons.stop_circle
                        : Icons.play_circle_outline,
                    color: AppTheme.starGold,
                    size: 36,
                  ),
                  onPressed: _togglePlayback,
                ),
                title: const Text('Nota de voz',
                    style: TextStyle(color: AppTheme.moonWhite)),
                subtitle: Text(
                  _isPlaying ? 'Reproduciendo...' : 'Toca para escuchar',
                  style: const TextStyle(color: AppTheme.cosmicGrey),
                ),
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}