// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:tuple/tuple.dart';

import '../ast/sass.dart';
import 'recursive_statement.dart';

/// Returns two lists of dependencies for [stylesheet].
///
/// The first is a list of URLs from all `@use` and `@forward` rules in
/// [stylesheet] (excluding built-in modules). The second is a list of all
/// imports in [stylesheet].
///
/// {@category Dependencies}
Tuple2<List<Uri>, List<Uri>> findDependencies(Stylesheet stylesheet) =>
    _FindDependenciesVisitor().run(stylesheet);

/// A visitor that traverses a stylesheet and records, all `@import`, `@use`,
/// and `@forward` rules (excluding built-in modules) it contains.
class _FindDependenciesVisitor with RecursiveStatementVisitor {
  final _usesAndForwards = <Uri>[];
  final _imports = <Uri>[];

  Tuple2<List<Uri>, List<Uri>> run(Stylesheet stylesheet) {
    visitStylesheet(stylesheet);
    return Tuple2(_usesAndForwards, _imports);
  }

  // These can never contain imports.
  void visitEachRule(EachRule node) {}
  void visitForRule(ForRule node) {}
  void visitIfRule(IfRule node) {}
  void visitWhileRule(WhileRule node) {}
  void visitCallableDeclaration(CallableDeclaration node) {}
  void visitInterpolation(Interpolation interpolation) {}
  void visitSupportsCondition(SupportsCondition condition) {}

  void visitUseRule(UseRule node) {
    if (node.url.scheme != 'sass') _usesAndForwards.add(node.url);
  }

  void visitForwardRule(ForwardRule node) {
    if (node.url.scheme != 'sass') _usesAndForwards.add(node.url);
  }

  void visitImportRule(ImportRule node) {
    for (var import in node.imports) {
      if (import is DynamicImport) _imports.add(import.url);
    }
  }
}
