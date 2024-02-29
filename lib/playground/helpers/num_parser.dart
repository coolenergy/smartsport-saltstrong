double doParse(dynamic value) => double.tryParse(value.toString()) ?? 0.0;
int doParseInt(dynamic value) => int.tryParse(value.toString()) ?? 0;
