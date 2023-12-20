class Utils {
  static double? parseDouble(String? value) {
    if (value == null) {
      return 0;
    }

    try {
      value = value.replaceAll(',', '.');
      final result = double.parse(value);

      if (result < 0) {
        return 0;
      }

      // return result;
      // Redondear a dos decimales
      return double.parse(result.toStringAsFixed(2));
    } catch (e) {
      return 0;
    }
  }

  static int? parseInt(String? value) {
    if (value == null) {
      return 0;
    }

    final List<String> parts =
        value.split(RegExp(r'[,.]')); // Dividir por comas y puntos
    final String firstPart = parts.first;

    // Intenta analizar el primer valor como un número entero
    try {
      return int.parse(firstPart);
    } catch (e) {
      return 0; // En caso de error, devuelve 0 o cualquier valor por defecto que desees
    }
  }
}