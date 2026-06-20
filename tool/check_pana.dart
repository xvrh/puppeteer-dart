import 'dart:convert';
import 'dart:io';

/// Runs `pana` and fails if the package no longer earns a perfect pub.dev
/// score, printing the breakdown of any section that lost points.
///
/// This catches regressions that other CI steps miss — e.g. a stray
/// `dart:io`/`dart:isolate` import that drops WASM/platform support, an
/// outdated dependency constraint, a documentation/convention gap — anything
/// pana scores. (`dart compile wasm` can't guard the platform score because it
/// tree-shakes unreachable imports; pana's static analysis does not.)
Future<void> main() async {
  final result = await Process.run('dart', [
    'pub',
    'global',
    'run',
    'pana',
    '--no-warning',
    '--json',
    '.',
  ]);
  if (result.exitCode != 0) {
    stderr.writeln(result.stderr);
    stderr.writeln('pana exited with ${result.exitCode}');
    exit(1);
  }

  final report = _extractJson(result.stdout as String);
  final tags = ((report['tags'] as List?) ?? const []).cast<String>();
  final scores = (report['scores'] as Map?) ?? const {};
  final granted = scores['grantedPoints'];
  final max = scores['maxPoints'];
  final sections =
      (((report['report'] as Map?)?['sections'] as List?) ?? const [])
          .cast<Map<String, dynamic>>();

  stdout.writeln('pana score: $granted / $max');
  stdout.writeln('tags: ${tags.join(', ')}');
  for (final section in sections) {
    stdout.writeln(
      '  [${section['grantedPoints']}/${section['maxPoints']}] '
      '${section['title']}',
    );
  }

  if (granted == max) {
    stdout.writeln('\nPana check passed: perfect $max/$max score.');
    return;
  }

  stderr.writeln(
    '\nPana check FAILED: score is $granted/$max (expected $max).',
  );
  for (final section in sections) {
    if (section['grantedPoints'] != section['maxPoints']) {
      stderr.writeln(
        '\n=== [${section['grantedPoints']}/${section['maxPoints']}] '
        '${section['title']} ===',
      );
      stderr.writeln(section['summary']);
    }
  }
  exit(1);
}

/// pana prints dependency-resolution noise before the JSON report; grab the
/// report object (the first line that is exactly `{`).
Map<String, dynamic> _extractJson(String output) {
  final lines = const LineSplitter().convert(output);
  final start = lines.indexWhere((l) => l.trim() == '{');
  if (start < 0) {
    stderr.writeln('Could not find JSON report in pana output.');
    exit(1);
  }
  return jsonDecode(lines.sublist(start).join('\n')) as Map<String, dynamic>;
}
