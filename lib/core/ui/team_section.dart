import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// A person on the Contributors page — a curated core member with a role, or a
/// community contributor auto-pulled from the repo's GitHub contributors.
class TeamMember {
  const TeamMember({
    required this.name,
    required this.role,
    required this.link,
    this.github,
    this.avatarUrl,
  });

  final String name;
  final String role;
  final String link; // opened on tap (GitHub / Discord / …)
  final String? github; // login → avatar + default link
  final String? avatarUrl;

  /// Avatar image url: an explicit one, else the GitHub avatar, else empty
  /// (the tile falls back to the name's initial).
  String get avatar =>
      avatarUrl ??
      (github != null ? 'https://github.com/$github.png?size=200' : '');
}

/// The lead developer, shown first on the Contributors page.
const List<TeamMember> kCoreTeam = [
  TeamMember(
    name: 'SuikaRYP',
    role: 'Lead Developer',
    github: 'SuikaRyp',
    link: 'https://github.com/SuikaRyp',
  ),
];

/// The contributor team, listed by hand.
const List<TeamMember> kFixedCommunity = [
  TeamMember(
    name: 'yogzoffc',
    role: 'Contributor',
    github: 'yogzoffc',
    link: 'https://github.com/yogzoffc',
  ),
  TeamMember(
    name: 'ObyMoods',
    role: 'Contributor',
    github: 'ObyMoods',
    link: 'https://github.com/ObyMoods',
  ),
  TeamMember(
    name: 'mangyaanzofficial',
    role: 'Contributor',
    github: 'mangyaanzofficial',
    link: 'https://github.com/mangyaanzofficial',
  ),
];

/// No GitHub logins are filtered any more: the community list is hand-listed.
const Set<String> kExcludedFromCommunity = {'suikaryp'};

/// Map GitHub's `/contributors` payload to community [TeamMember]s: drop the
/// core + ghost logins and bots, tag everyone else as "Contributor". GitHub
/// returns them sorted by contribution count, which we keep.
List<TeamMember> parseCommunity(List<dynamic> json) {
  final out = <TeamMember>[];
  for (final e in json) {
    if (e is! Map) continue;
    final login = (e['login'] ?? '').toString();
    if (login.isEmpty) continue;
    final type = (e['type'] ?? '').toString();
    if (type == 'Bot' || login.toLowerCase().endsWith('[bot]')) continue;
    if (kExcludedFromCommunity.contains(login.toLowerCase())) continue;
    final avatar = (e['avatar_url'] ?? '').toString();
    out.add(
      TeamMember(
        name: login,
        role: 'Contributor',
        github: login,
        link: (e['html_url'] ?? 'https://github.com/$login').toString(),
        avatarUrl: avatar.isEmpty ? null : avatar,
      ),
    );
  }
  return out;
}

/// Community contributors are hand-listed in [kFixedCommunity]; nothing is
/// pulled from GitHub any more.
Future<List<TeamMember>> fetchCommunity() async => const [];

/// Circular avatar for a contributor — GitHub/explicit image with the name's
/// initial as the fallback.
class TeamAvatar extends StatelessWidget {
  const TeamAvatar({
    super.key,
    required this.url,
    required this.name,
    this.size = 42,
  });

  final String url;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.08),
      ),
      child: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: TextStyle(
          fontFamily: AppText.fontFamily,
          fontFamilyFallback: AppText.fontFamilyFallback,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.4,
        ),
      ),
    );
    if (url.isEmpty) return fallback;
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 180),
        placeholder: (_, _) => fallback,
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }
}
