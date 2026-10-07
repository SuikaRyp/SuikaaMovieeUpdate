import 'package:flutter/foundation.dart';

import '../hive/safe_box.dart';
import 'provider_registry.dart';
import 'provider_repo_registry.dart';

/// Manifest of the SuikaMovie source repo (SuikaRyp/SuikaMovieProvider).
const String kDefaultProviderRepoUrl =
    'https://raw.githubusercontent.com/SuikaRyp/SuikaMovieProvider/refs/heads/main/index.json';

/// Source ids that need user-supplied credentials (an API key) and therefore
/// can't work out of the box. They stay listed in the repo, just not
/// auto-installed.
const Set<String> _needsUserKey = {'torbox'};

/// First-launch seeding: adds [kDefaultProviderRepoUrl] and installs its
/// sources, so a fresh install isn't left with "No source has this yet".
///
/// Runs ONCE (flag in its own Hive box), and only when nothing is installed:
/// a user who later uninstalls or removes the repo is never re-seeded. A
/// failed attempt (offline, repo down) leaves the flag unset so the next
/// launch tries again. Never throws — it must not affect boot.
class DefaultSourcesSeeder {
  DefaultSourcesSeeder({required this.repos, required this.registry});

  final ProviderReposRegistry repos;
  final ProviderRegistry registry;

  static const String _boxName = 'default_sources_seed';
  static const String _flagKey = 'done_v1';

  /// Returns the number of sources installed (0 when skipped or failed).
  Future<int> seedIfNeeded() async {
    try {
      final box = await openBoxSafely<dynamic>(_boxName);
      if (box.get(_flagKey) == true) return 0;

      // Existing users / restored backups already have sources: leave alone.
      if (registry.getAll().isNotEmpty) {
        await box.put(_flagKey, true);
        return 0;
      }

      final repo = await repos.fetchAndCache(kDefaultProviderRepoUrl);
      var installed = 0;
      for (final source in repo.sources) {
        if (_needsUserKey.contains(source.id.toLowerCase())) continue;
        try {
          await registry.install(
            sourceId: source.id,
            fileUrl: repos.resolveFileUrl(repo, source),
            logoUrl: ProviderReposRegistry.resolveLogoUrl(repo, source) ?? '',
            repoUrl: repo.url,
            displayName: source.name,
            version: source.version,
            force: true,
          );
          installed++;
        } catch (e) {
          debugPrint('[seed] could not install ${source.id}: $e');
        }
      }
      // Only mark done if something actually landed; otherwise retry next launch.
      if (installed > 0) await box.put(_flagKey, true);
      debugPrint('[seed] installed $installed default source(s)');
      return installed;
    } catch (e) {
      debugPrint('[seed] default sources not seeded: $e');
      return 0;
    }
  }
}
