import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HomeHeader(theme: theme),
                    const SizedBox(height: 24),
                    const _TodayPlanCard(),
                    const SizedBox(height: 20),
                    _SectionTitle(
                      title: 'Szybkie akcje',
                      actionLabel: 'Zobacz więcej',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    const _QuickActionsRow(),
                    const SizedBox(height: 24),
                    _SectionTitle(
                      title: 'Lista zakupów',
                      actionLabel: 'Otwórz',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    const _ShoppingPreviewCard(),
                    const SizedBox(height: 24),
                    _SectionTitle(
                      title: 'W tym tygodniu',
                      actionLabel: 'Plan tygodnia',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    const _WeekPreviewCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final ThemeData theme;

  const _HomeHeader({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dzień dobry',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Wspólnicy',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Zaplanuj posiłki i zakupy na ten tydzień.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF2563EB),
          ),
        ),
      ],
    );
  }
}

class _TodayPlanCard extends StatelessWidget {
  const _TodayPlanCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF1D4ED8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F2563EB),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x1FFFFFFF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Dzisiejszy plan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Wtorek',
            style: TextStyle(
              color: Color(0xFFDCE9FF),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Makaron z kurczakiem i warzywami',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Zaplanowano wspólny obiad na 18:00. Brakuje 3 produktów do zakupów.',
            style: TextStyle(
              color: Color(0xFFEAF2FF),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1D4ED8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Zobacz plan'),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 54,
                height: 54,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0x66FFFFFF)),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Icon(Icons.add_rounded),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  const _SectionTitle({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _QuickActionTile(
            icon: Icons.calendar_month_rounded,
            label: 'Dodaj posiłek',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _QuickActionTile(
            icon: Icons.shopping_cart_checkout_rounded,
            label: 'Dodaj produkt',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _QuickActionTile(
            icon: Icons.menu_book_rounded,
            label: 'Nowy przepis',
          ),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickActionTile({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2563EB),
            ),
          ),
          const Spacer(),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
          ),
        ],
      ),
    );
  }
}

class _ShoppingPreviewCard extends StatelessWidget {
  const _ShoppingPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: const [
          _ShoppingRow(
            title: 'Makaron',
            subtitle: '2 opakowania',
            checked: true,
          ),
          Divider(height: 24),
          _ShoppingRow(
            title: 'Pomidory',
            subtitle: '6 sztuk',
            checked: false,
          ),
          Divider(height: 24),
          _ShoppingRow(
            title: 'Mozzarella',
            subtitle: '3 opakowania',
            checked: false,
          ),
        ],
      ),
    );
  }
}

class _ShoppingRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool checked;

  const _ShoppingRow({
    required this.title,
    required this.subtitle,
    required this.checked,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: checked ? const Color(0xFF2563EB) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: checked
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFCBD5E1),
            ),
          ),
          child: checked
              ? const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Colors.white,
                )
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF64748B),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeekPreviewCard extends StatelessWidget {
  const _WeekPreviewCard();

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Śr', 'Tacos z warzywami'),
      ('Czw', 'Zupa pomidorowa'),
      ('Pt', 'Ryż z kurczakiem'),
      ('Sob', 'Domowa pizza'),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          item.$1,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2563EB),
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        item.$2,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                            ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}