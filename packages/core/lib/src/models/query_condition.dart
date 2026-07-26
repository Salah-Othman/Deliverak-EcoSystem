import 'package:equatable/equatable.dart';

enum QueryOperator {
  isEqualTo,
  isNotEqualTo,
  isLessThan,
  isLessThanOrEqualTo,
  isGreaterThan,
  isGreaterThanOrEqualTo,
  arrayContains,
}

class QueryCondition extends Equatable {
  final String field;
  final dynamic value;
  final QueryOperator operator;

  const QueryCondition({
    required this.field,
    required this.value,
    this.operator = QueryOperator.isEqualTo,
  });

  @override
  List<Object?> get props => [field, value, operator];
}
