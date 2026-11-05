import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_error.dart';
import '../../../core/format/dates.dart';
import '../../../core/theme/tokens.dart';
import '../../attachment/presentation/photo_edits.dart';
import '../../attachment/presentation/widgets/photo_picker_row.dart';
import '../../attachment/providers/attachment_providers.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../data/activity_models.dart';
import '../providers/activity_providers.dart';

const _photoLimit = 5;

/// Tambah baru (opsional dengan [initialDate]), atau edit [activity].
class ActivityFormArgs {
  const ActivityFormArgs({this.activity, this.initialDate});

  final Activity? activity;
  final DateTime? initialDate;
}

/// Form kegiatan (S-09).
class ActivityFormScreen extends ConsumerStatefulWidget {
  const ActivityFormScreen({super.key, this.args = const ActivityFormArgs()});

  final ActivityFormArgs args;

  @override
  ConsumerState<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends ConsumerState<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();
  late final PhotoEdits _photos;

  late DateTime _date;

  /// `HH:mm`; null = seharian.
  String? _time;
  bool _important = false;
  bool _busy = false;
  String? _error;

  /// Terisi setelah kegiatan tersimpan; sejak itu Simpan tidak boleh mengirim ulang.
  String? _savedId;

  Activity? get _activity => widget.args.activity;
  bool get _isEdit => _activity != null;

  void _rebuild() => setState(() {});

  @override
  void initState() {
    super.initState();
    _date = widget.args.initialDate ?? DateTime.now();
    final activity = _activity;
    if (activity != null) {
      _date = DateTime.parse(activity.date);
      _time = activity.time;
      _important = activity.isImportant;
      _title.text = activity.title;
      _location.text = activity.location ?? '';
      _description.text = activity.description ?? '';
    }
    _photos = PhotoEdits(activity?.attachments ?? const [])
      ..addListener(_rebuild);
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _description.dispose();
    _photos.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final current = _time?.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: current == null
          ? TimeOfDay.now()
          : TimeOfDay(
              hour: int.parse(current[0]),
              minute: int.parse(current[1]),
            ),
    );
    if (picked == null) return;
    String pad(int value) => value.toString().padLeft(2, '0');
    setState(() => _time = '${pad(picked.hour)}:${pad(picked.minute)}');
  }

  Map<String, Object?> _body() {
    final data = <String, Object?>{
      'title': _title.text.trim(),
      'date': dateKey(_date),
      'isImportant': _important,
    };
    // Saat edit, nilai kosong berarti dihapus.
    void optional(String key, String? value) {
      final text = value?.trim();
      if (text != null && text.isNotEmpty) {
        data[key] = text;
      } else if (_isEdit) {
        data[key] = null;
      }
    }

    optional('time', _time);
    optional('location', _location.text);
    optional('description', _description.text);
    return data;
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState!.validate();
    setState(() => _error = null);
    if (!valid || _busy) return;

    setState(() => _busy = true);
    final api = ref.read(activityApiProvider);
    final activity = _activity;
    final String savedId;
    try {
      if (activity == null) {
        savedId = await api.create(_body());
      } else {
        await api.update(activity.id, _body());
        savedId = activity.id;
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.details.values.firstOrNull ?? e.message;
          _busy = false;
        });
      }
      return;
    }
    if (!mounted) return;
    setState(() => _savedId = savedId);
    await _syncPhotos();
  }

  Future<void> _syncPhotos() async {
    setState(() => _busy = true);
    final done = await _photos.sync(
      ref.read(attachmentApiProvider),
      activityId: _savedId,
      subject: 'Kegiatan',
    );
    if (!mounted) return;
    if (done) return _finish();
    refreshMoney(ref);
    setState(() => _busy = false);
  }

  void _finish() {
    refreshMoney(ref);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Kegiatan tersimpan')));
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      // Kegiatan sudah tersimpan: keluar harus lewat _finish supaya layar asal ikut segar.
      canPop: _savedId == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_busy) _finish();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? 'Ubah kegiatan' : 'Tambah kegiatan'),
        ),
        body: Form(
          key: _formKey,
          // Bukan ListView: field yang ter-scroll keluar layar tetap harus ikut divalidasi.
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                IgnorePointer(
                  ignoring: _savedId != null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _title,
                        autofocus: !_isEdit,
                        maxLength: 100,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(labelText: 'Judul'),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? 'Judul wajib diisi'
                            : null,
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today_rounded),
                        title: Text(formatLongDate(_date)),
                        onTap: _pickDate,
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.schedule_rounded),
                        title: Text(formatActivityTime(_time)),
                        trailing: _time == null
                            ? null
                            : TextButton(
                                onPressed: () => setState(() => _time = null),
                                child: const Text('Seharian'),
                              ),
                        onTap: _pickTime,
                      ),
                      TextFormField(
                        controller: _location,
                        maxLength: 100,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        decoration: const InputDecoration(
                          labelText: 'Lokasi (opsional)',
                        ),
                      ),
                      TextFormField(
                        controller: _description,
                        maxLength: 1000,
                        maxLines: null,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi (opsional)',
                        ),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Tandai penting'),
                        value: _important,
                        onChanged: (value) =>
                            setState(() => _important = value),
                      ),
                      const SizedBox(height: Spacing.sm),
                      PhotoPickerRow(
                        edits: _photos,
                        label: 'Foto kegiatan',
                        limit: _photoLimit,
                        locked: _savedId != null,
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: Spacing.sm),
                  Text(
                    _error!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                PhotoSaveButtons(
                  edits: _photos,
                  busy: _busy,
                  onSave: _submit,
                  onRetry: _syncPhotos,
                  onSkip: _finish,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
