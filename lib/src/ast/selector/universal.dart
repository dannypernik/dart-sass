// Copyright 2016 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:meta/meta.dart';

import '../../extend/functions.dart';
import '../../visitor/interface/selector.dart';
import '../selector.dart';

/// Matches any element in the given namespace.
///
/// {@category AST}
@sealed
class UniversalSelector extends SimpleSelector {
  /// The selector namespace.
  ///
  /// If this is `null`, this matches all elements in the default namespace. If
  /// it's the empty string, this matches all elements that aren't in any
  /// namespace. If it's `*`, this matches all elements in any namespace.
  /// Otherwise, it matches all elements in the given namespace.
  final String? namespace;

  int get specificity => 0;

  UniversalSelector({this.namespace});

  T accept<T>(SelectorVisitor<T> visitor) =>
      visitor.visitUniversalSelector(this);

  /// @nodoc
  @internal
  List<SimpleSelector>? unify(List<SimpleSelector> compound) {
    var first = compound.first;
    if (first is UniversalSelector || first is TypeSelector) {
      var unified = unifyUniversalAndElement(this, first);
      if (unified == null) return null;
      return [unified, ...compound.skip(1)];
    } else if (compound.length == 1 &&
        first is PseudoSelector &&
        (first.isHost || first.isHostContext)) {
      return null;
    }

    if (namespace != null && namespace != "*") return [this, ...compound];
    if (compound.isNotEmpty) return compound;
    return [this];
  }

  bool isSuperselector(SimpleSelector other) {
    if (namespace == '*') return true;
    if (other is TypeSelector) return namespace == other.name.namespace;
    if (other is UniversalSelector) return namespace == other.namespace;
    return namespace == null || super.isSuperselector(other);
  }

  bool operator ==(Object other) =>
      other is UniversalSelector && other.namespace == namespace;

  int get hashCode => namespace.hashCode;
}
