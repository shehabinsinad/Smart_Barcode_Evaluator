import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {
  Future<Map<String, dynamic>> getProductDetails(String barcode) async {
    final url = 'https://world.openfoodfacts.org/api/v0/product/$barcode.json';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['status'] == 1) {
        final product = jsonData['product'];

        double calories = double.tryParse(
                product['nutriments']?['energy-kcal_100g']?.toString() ?? '0') ??
            0;
        double protein = double.tryParse(
                product['nutriments']?['proteins_100g']?.toString() ?? '0') ??
            0;
        double carbs = double.tryParse(
                product['nutriments']?['carbohydrates_100g']?.toString() ?? '0') ??
            0;
        double fat = double.tryParse(
                product['nutriments']?['fat_100g']?.toString() ?? '0') ??
            0;
        double sugars = double.tryParse(
                product['nutriments']?['sugars_100g']?.toString() ?? '0') ??
            0;

        // Process allergens from API.
        List<dynamic>? allergensList = product['allergens_tags'];
        String allergens = "";
        if (allergensList != null && allergensList.isNotEmpty) {
          allergens = allergensList
              .map((e) => e.toString().toLowerCase().replaceAll("en:", "").trim())
              .join(", ");
        }

        // Determine product name.
        String productName = product["product_name"] ?? "Unknown Product";

        
        if (productName.toLowerCase().contains("milma") ||
            productName.toLowerCase().contains("milk")) {
          if (!allergens.contains("dairy")) {
            allergens = allergens.isEmpty ? "dairy" : "$allergens, dairy";
          }
        }
        
        if (productName.toLowerCase().contains("snickers") ||
            productName.toLowerCase().contains("peanut")) {
          if (!allergens.contains("peanuts")) {
            allergens = allergens.isEmpty ? "peanuts" : "$allergens, peanuts";
          }
        }

        // Build a nutritional info string.
        String nutrients =
            "Protein: ${protein}g, Carbs: ${carbs}g, Fat: ${fat}g, Sugars: ${sugars}g";

        return {
          "name": productName,
          "calories": calories,
          "protein": protein,
          "carbs": carbs,
          "fat": fat,
          "sugars": sugars,
          "nutrients": nutrients,
          "allergens": allergens,
        };
      } else {
        throw Exception("Product not found");
      }
    } else {
      throw Exception("Failed to load product details");
    }
  }
}
