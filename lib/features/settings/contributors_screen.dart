import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/ui/settings_widgets.dart';
import '../../l10n/l10n.dart';
import '../../core/ui/team_section.dart';

/// The people behind SuikaMovie: the curated core team (with roles) followed by
/// "Community Contributors" — everyone else who's contributed on GitHub, pulled
/// live. The community list is empty until someone new contributes.
class ContributorsScreen extends StatefulWidget {
  const ContributorsScreen({super.key});

  @override
  State<ContributorsScreen> createState() => _ContributorsScreenState();
}

class _ContributorsScreenState extends State<ContributorsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: settingsAppBar(context.l10n.contributors),
      body: ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 28),
        children: [
          SettingsSectionLabel(context.l10n.team, first: true, muted: true),
          for (final m in kCoreTeam)
            SettingsCard(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              children: [_ContributorTile(member: m)],
            ),
          SettingsSectionLabel(context.l10n.communityContributors, muted: true),
          // Hand-listed first — people with no commits to their name, so the
          // GitHub fetch below can't turn them up.
          for (final m in kFixedCommunity)
            SettingsCard(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              children: [_ContributorTile(member: m)],
            ),
        ],
      ),
    );
  }
}

/// One contributor row: avatar, name, role, and an open-link affordance.
class _ContributorTile extends StatelessWidget {
  const _ContributorTile({required this.member});

  final TeamMember member;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(member.link);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
      },
      splashColor: AppColors.accent.withValues(alpha: 0.08),
      highlightColor: AppColors.accent.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          children: [
            TeamAvatar(url: member.avatar, name: member.name, size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: AppText.headline.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member.role,
                    style: AppText.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_outward_rounded,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
