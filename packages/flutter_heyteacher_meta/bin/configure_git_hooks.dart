/// Creates `.git/hooks/commit-msg` and `.git/hooks/pre-commit`
library;

import 'package:flutter_heyteacher_meta/src/commands.dart';

void main(List<String> arguments) => configureGitHooks();
