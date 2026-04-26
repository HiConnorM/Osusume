import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/restaurant.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ReservationScreen extends StatefulWidget {
  final Restaurant restaurant;

  const ReservationScreen({super.key, required this.restaurant});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  int _partySize = 2;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  String _time = '19:00';
  final Set<String> _allergies = {};
  String _notes = '';
  bool _generated = false;
  bool _generating = false;

  Restaurant get r => widget.restaurant;

  final _times = [
    '11:30', '12:00', '12:30', '13:00', '18:00',
    '18:30', '19:00', '19:30', '20:00', '20:30', '21:00',
  ];

  String get _generatedMessage => '''
予約のお願いがあります。

${_formatDate(_date)}の${_time}に${_partySize}名でご予約をお願いできますでしょうか。

${_allergies.isNotEmpty ? '※食物アレルギーがございます：${_allergies.join('、')}。対応していただけますか？\n' : ''}${_notes.isNotEmpty ? '※${_notes}\n' : ''}
よろしくお願いいたします。
''';

  String get _englishVersion => '''
Hello, I would like to make a reservation.

Could I book a table for $_partySize ${_partySize == 1 ? 'person' : 'people'} at $_time on ${_formatDateEn(_date)}?

${_allergies.isNotEmpty ? 'Please note: one of our party has a food allergy to ${_allergies.join(', ')}. Can you accommodate this?\n' : ''}${_notes.isNotEmpty ? 'Additional note: $_notes\n' : ''}
Thank you very much.
''';

  String _formatDate(DateTime d) {
    return '${d.year}年${d.month}月${d.day}日';
  }

  String _formatDateEn(DateTime d) {
    final months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[d.month]} ${d.day}, ${d.year}';
  }

  Future<void> _generate() async {
    setState(() => _generating = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        _generating = false;
        _generated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Reservation Helper'),
      ),
      body: _generated ? _buildResult(context) : _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Restaurant chip
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _cuisineEmoji(r.cuisine),
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.nameEn, style: AppTextStyles.labelLarge),
                      Text(r.nameJa, style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          Text('Reservation details', style: AppTextStyles.headingSmall),
          const SizedBox(height: 16),

          // Party size
          _SectionLabel('Party size'),
          const SizedBox(height: 10),
          Row(
            children: [
              _CounterButton(
                icon: Icons.remove,
                onTap: () {
                  if (_partySize > 1) setState(() => _partySize--);
                },
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$_partySize ${_partySize == 1 ? 'person' : 'people'}',
                    style: AppTextStyles.headingMedium,
                  ),
                ),
              ),
              _CounterButton(
                icon: Icons.add,
                onTap: () {
                  if (_partySize < 20) setState(() => _partySize++);
                },
              ),
            ],
          ),

          const SizedBox(height: 20),
          _SectionLabel('Date'),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: AppColors.primary,
                        ),
                  ),
                  child: child!,
                ),
              );
              if (d != null) setState(() => _date = d);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(_formatDateEn(_date), style: AppTextStyles.bodyLarge),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          _SectionLabel('Time'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _times.map((t) {
              final selected = t == _time;
              return GestureDetector(
                onTap: () => setState(() => _time = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.divider,
                    ),
                  ),
                  child: Text(
                    t,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: selected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          _SectionLabel('Allergies (optional)'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Shellfish', 'Nuts', 'Gluten', 'Dairy', 'Eggs', 'Soy', 'Pork']
                .map((a) {
              final selected = _allergies.contains(a);
              return GestureDetector(
                onTap: () => setState(() {
                  if (selected) {
                    _allergies.remove(a);
                  } else {
                    _allergies.add(a);
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.warning.withOpacity(0.1)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? AppColors.warning : AppColors.divider,
                    ),
                  ),
                  child: Text(
                    '${selected ? '⚠️ ' : ''}$a',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: selected ? AppColors.warning : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          _SectionLabel('Special requests (optional)'),
          const SizedBox(height: 10),
          TextField(
            onChanged: (v) => _notes = v,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Birthday celebration, high chair needed, window seat...',
            ),
          ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _generating ? null : _generate,
              child: _generating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Generate Japanese message'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.tagGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Text('✅', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Text(
                  'Message ready!',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.tagGreenText,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text('Japanese message', style: AppTextStyles.headingSmall),
          const SizedBox(height: 4),
          Text(
            'Send this via LINE, email, or read it on your phone to staff.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 12),

          _MessageBox(
            text: _generatedMessage,
            label: '日本語',
            onCopy: () {
              Clipboard.setData(ClipboardData(text: _generatedMessage));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Japanese message copied')),
              );
            },
          ),

          const SizedBox(height: 20),
          Text('English version (for reference)', style: AppTextStyles.headingSmall),
          const SizedBox(height: 12),

          _MessageBox(
            text: _englishVersion,
            label: 'English',
            onCopy: () {
              Clipboard.setData(ClipboardData(text: _englishVersion));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('English message copied')),
              );
            },
          ),

          const SizedBox(height: 24),

          // How to use
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How to use this', style: AppTextStyles.headingSmall),
                const SizedBox(height: 12),
                ...[
                  ('📱', 'Show the Japanese message on your phone screen to the restaurant staff'),
                  ('📞', 'If calling, read the message aloud or hand your phone to a Japanese speaker to call for you'),
                  ('💬', 'Send via LINE, Instagram DM, or email if the restaurant accepts digital bookings'),
                  ('🏨', 'Your hotel concierge can often make the call on your behalf'),
                ].map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tip.$1, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(tip.$2, style: AppTextStyles.bodySmall),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),

          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => setState(() => _generated = false),
            child: const Text('Edit details'),
          ),
        ],
      ),
    );
  }

  String _cuisineEmoji(String cuisine) {
    return switch (cuisine.toLowerCase()) {
      'ramen' => '🍜',
      'sushi' => '🍣',
      'yakitori' => '🍢',
      _ => '🍽️',
    };
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CounterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  final String text;
  final String label;
  final VoidCallback onCopy;

  const _MessageBox({
    required this.text,
    required this.label,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                Text(label, style: AppTextStyles.labelSmall),
                const Spacer(),
                TextButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: SelectableText(
              text.trim(),
              style: AppTextStyles.bodyMedium.copyWith(height: 1.7),
            ),
          ),
        ],
      ),
    );
  }
}
