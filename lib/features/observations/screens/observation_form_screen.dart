import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/location_service.dart';
import '../../../data/models/observation_model.dart';
import '../observation_provider.dart';

class ObservationFormScreen extends StatefulWidget {
  const ObservationFormScreen({super.key});

  @override
  State<ObservationFormScreen> createState() => _ObservationFormScreenState();
}

class _ObservationFormScreenState extends State<ObservationFormScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _tituloCtrl   = TextEditingController();
  final _descCtrl     = TextEditingController();
  final _ubicTxtCtrl  = TextEditingController();
  final _durCtrl      = TextEditingController();

  // Estado del formulario
  DateTime  _fechaHora         = DateTime.now();
  String    _categoria         = AppConstants.categorias.first;
  String    _condiciones       = AppConstants.condicionesCielo.first;
  double?   _lat;
  double?   _lng;
  bool      _loadingGps        = false;
  File?     _fotoFile;
  String?   _audioPath;
  bool      _isRecording       = false;
  bool      _isPlayingAudio    = false;
  bool      _saving            = false;

  final _imagePicker  = ImagePicker();
  final _audioRecord  = AudioRecorder();
  final _audioPlayer  = AudioPlayer();

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _ubicTxtCtrl.dispose();
    _durCtrl.dispose();
    _audioRecord.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ── GPS ────────────────────────────────────────────────────
  Future<void> _getLocation() async {
    setState(() => _loadingGps = true);
    final pos = await LocationService.getCurrentPosition();
    setState(() {
      _loadingGps = false;
      if (pos != null) {
        _lat = pos.latitude;
        _lng = pos.longitude;
      }
    });
    if (pos == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener la ubicación GPS'),
          backgroundColor: AppTheme.meteorRed,
        ),
      );
    }
  }

  // ── Foto ───────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source:     source,
      imageQuality: 80,
      maxWidth:   1280,
    );
    if (picked != null) {
      setState(() => _fotoFile = File(picked.path));
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context:         context,
      backgroundColor: AppTheme.deepBlue,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppTheme.starGold),
              title: const Text('Tomar foto',
                  style: TextStyle(color: AppTheme.moonWhite)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppTheme.starGold),
              title: const Text('Elegir de galería',
                  style: TextStyle(color: AppTheme.moonWhite)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Audio ──────────────────────────────────────────────────
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioRecord.stop();
      setState(() {
        _isRecording = false;
        _audioPath   = path;
      });
    } else {
      final hasPermission = await _audioRecord.hasPermission();
      if (!hasPermission) return;

      final dir  = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/obs_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecord.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      setState(() => _isRecording = true);
    }
  }

  Future<void> _togglePlayback() async {
    if (_audioPath == null) return;
    if (_isPlayingAudio) {
      await _audioPlayer.stop();
      setState(() => _isPlayingAudio = false);
    } else {
      await _audioPlayer.play(DeviceFileSource(_audioPath!));
      setState(() => _isPlayingAudio = true);
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlayingAudio = false);
      });
    }
  }

  // ── Fecha y hora ───────────────────────────────────────────
  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context:     context,
      initialDate: _fechaHora,
      firstDate:   DateTime(2020),
      lastDate:    DateTime.now(),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context:     context,
      initialTime: TimeOfDay.fromDateTime(_fechaHora),
    );
    if (time == null) return;

    setState(() {
      _fechaHora = DateTime(
        date.year, date.month, date.day,
        time.hour, time.minute,
      );
    });
  }

  // ── Guardar ────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final obs = ObservationModel(
      titulo:          _tituloCtrl.text.trim(),
      fechaHora:       _fechaHora.toIso8601String(),
      lat:             _lat,
      lng:             _lng,
      ubicacionTexto:  _ubicTxtCtrl.text.trim().isEmpty
                           ? null
                           : _ubicTxtCtrl.text.trim(),
      duracionSeg:     int.tryParse(_durCtrl.text),
      categoria:       _categoria,
      condicionesCielo: _condiciones,
      descripcion:     _descCtrl.text.trim(),
      fotoPath:        _fotoFile?.path,
      audioPath:       _audioPath,
      creadoEn:        DateTime.now().toIso8601String(),
    );

    final ok = await context.read<ObservationProvider>().saveObservation(obs);

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar la observación'),
          backgroundColor: AppTheme.meteorRed,
        ),
      );
    }
  }

  // ── UI helpers ─────────────────────────────────────────────
  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color:      AppTheme.starGold,
        fontSize:   13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva observación'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppTheme.starGold),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('GUARDAR',
                  style: TextStyle(color: AppTheme.starGold,
                      fontWeight: FontWeight.bold)),
            ),
        ],
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // ── DATOS BÁSICOS ──────────────────────────────
            _sectionTitle('DATOS BÁSICOS'),

            TextFormField(
              controller: _tituloCtrl,
              style: const TextStyle(color: AppTheme.moonWhite),
              decoration: const InputDecoration(
                labelText: 'Título *',
                hintText:  'Ej: Halo solar, Lluvia de Perseidas...',
                prefixIcon: Icon(Icons.title, color: AppTheme.cosmicGrey),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'El título es requerido' : null,
            ),
            const SizedBox(height: 12),

            // Fecha y hora
            InkWell(
              onTap: _pickDateTime,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha y hora *',
                  prefixIcon: Icon(Icons.schedule, color: AppTheme.cosmicGrey),
                ),
                child: Text(
                  DateFormat('dd/MM/yyyy  HH:mm').format(_fechaHora),
                  style: const TextStyle(color: AppTheme.moonWhite),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Categoría
            DropdownButtonFormField<String>(
              value: _categoria,
              dropdownColor: AppTheme.deepBlue,
              style: const TextStyle(color: AppTheme.moonWhite),
              decoration: const InputDecoration(
                labelText: 'Categoría *',
                prefixIcon: Icon(Icons.label_outline,
                    color: AppTheme.cosmicGrey),
              ),
              items: AppConstants.categorias.map((c) =>
                DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _categoria = v!),
            ),
            const SizedBox(height: 12),

            // Condiciones del cielo
            DropdownButtonFormField<String>(
              value: _condiciones,
              dropdownColor: AppTheme.deepBlue,
              style: const TextStyle(color: AppTheme.moonWhite),
              decoration: const InputDecoration(
                labelText: 'Condiciones del cielo *',
                prefixIcon: Icon(Icons.cloud_outlined,
                    color: AppTheme.cosmicGrey),
              ),
              items: AppConstants.condicionesCielo.map((c) =>
                DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _condiciones = v!),
            ),
            const SizedBox(height: 12),

            // Duración
            TextFormField(
              controller: _durCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.moonWhite),
              decoration: const InputDecoration(
                labelText: 'Duración estimada (segundos)',
                prefixIcon: Icon(Icons.timer_outlined,
                    color: AppTheme.cosmicGrey),
              ),
            ),

            // ── DESCRIPCIÓN ────────────────────────────────
            _sectionTitle('DESCRIPCIÓN'),

            TextFormField(
              controller: _descCtrl,
              maxLines:   4,
              style: const TextStyle(color: AppTheme.moonWhite),
              decoration: const InputDecoration(
                labelText: 'Descripción detallada *',
                hintText:  'Qué viste, dirección (N/S/E/O), altura estimada...',
                alignLabelWithHint: true,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty)
                      ? 'La descripción es requerida'
                      : null,
            ),

            // ── UBICACIÓN ──────────────────────────────────
            _sectionTitle('UBICACIÓN'),

            // GPS
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:        AppTheme.deepBlue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.nebulaPurple.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Icon(
                    _lat != null ? Icons.gps_fixed : Icons.gps_not_fixed,
                    color: _lat != null
                        ? AppTheme.auroraGreen
                        : AppTheme.cosmicGrey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _lat != null
                          ? 'GPS: ${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}'
                          : 'Sin ubicación GPS',
                      style: TextStyle(
                        color: _lat != null
                            ? AppTheme.moonWhite
                            : AppTheme.cosmicGrey,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (_loadingGps)
                    const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    TextButton(
                      onPressed: _getLocation,
                      child: Text(_lat != null ? 'Actualizar' : 'Capturar'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Ubicación en texto
            TextFormField(
              controller: _ubicTxtCtrl,
              style: const TextStyle(color: AppTheme.moonWhite),
              decoration: const InputDecoration(
                labelText: 'Ubicación en texto (opcional)',
                hintText:  'Ej: Sector La Julia, Santo Domingo',
                prefixIcon: Icon(Icons.place_outlined,
                    color: AppTheme.cosmicGrey),
              ),
            ),

            // ── MULTIMEDIA ─────────────────────────────────
            _sectionTitle('MULTIMEDIA'),

            // Foto
            GestureDetector(
              onTap: _showImageSourceSheet,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color:        AppTheme.deepBlue,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.nebulaPurple.withOpacity(0.5)),
                  image: _fotoFile != null
                      ? DecorationImage(
                          image: FileImage(_fotoFile!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _fotoFile == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined,
                              color: AppTheme.cosmicGrey, size: 36),
                          SizedBox(height: 8),
                          Text('Agregar foto (opcional)',
                              style: TextStyle(color: AppTheme.cosmicGrey)),
                        ],
                      )
                    : Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: GestureDetector(
                            onTap: () => setState(() => _fotoFile = null),
                            child: const CircleAvatar(
                              radius: 14,
                              backgroundColor: AppTheme.meteorRed,
                              child: Icon(Icons.close,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Audio
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:        AppTheme.deepBlue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.nebulaPurple.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  // Botón grabar/parar
                  IconButton(
                    onPressed: _toggleRecording,
                    icon: Icon(
                      _isRecording ? Icons.stop_circle : Icons.mic_outlined,
                      color: _isRecording
                          ? AppTheme.meteorRed
                          : AppTheme.starGold,
                      size: 32,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _isRecording
                          ? 'Grabando...'
                          : _audioPath != null
                              ? 'Nota de voz grabada ✓'
                              : 'Grabar nota de voz (opcional)',
                      style: TextStyle(
                        color: _isRecording
                            ? AppTheme.meteorRed
                            : _audioPath != null
                                ? AppTheme.auroraGreen
                                : AppTheme.cosmicGrey,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  // Reproducir (solo si hay audio)
                  if (_audioPath != null && !_isRecording)
                    IconButton(
                      onPressed: _togglePlayback,
                      icon: Icon(
                        _isPlayingAudio
                            ? Icons.stop
                            : Icons.play_circle_outline,
                        color: AppTheme.starGold,
                      ),
                    ),
                  // Eliminar audio
                  if (_audioPath != null && !_isRecording)
                    IconButton(
                      onPressed: () => setState(() => _audioPath = null),
                      icon: const Icon(Icons.delete_outline,
                          color: AppTheme.meteorRed),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}