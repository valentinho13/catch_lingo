import 'package:flutter/material.dart';

import '../models/catch_word.dart';

IconData catchWordIcon(CatchWord word) {
  return catchWordIconForSource(word.source);
}

IconData catchWordIconForSource(String source) {
  return switch (source.toLowerCase()) {
    'coffee' => Icons.local_cafe_rounded,
    'tea' => Icons.emoji_food_beverage_rounded,
    'cup' => Icons.local_drink_rounded,
    'glass' => Icons.wine_bar_rounded,
    'table' => Icons.table_restaurant_rounded,
    'chair' => Icons.chair_rounded,
    'water' => Icons.water_drop_rounded,
    'rain' => Icons.water_drop_rounded,
    'fish' => Icons.set_meal_rounded,
    'car' => Icons.directions_car_filled_rounded,
    'motorcycle' => Icons.two_wheeler_rounded,
    'bicycle' => Icons.pedal_bike_rounded,
    'bus' => Icons.directions_bus_filled_rounded,
    'tree' => Icons.park_rounded,
    'flower' => Icons.local_florist_rounded,
    'leaf' => Icons.eco_rounded,
    'sun' => Icons.wb_sunny_rounded,
    'sky' => Icons.cloud_rounded,
    'stone' => Icons.landscape_rounded,
    'rice' => Icons.rice_bowl_rounded,
    'chicken' => Icons.restaurant_rounded,
    'bread' => Icons.bakery_dining_rounded,
    'milk' => Icons.local_drink_rounded,
    'apple' => Icons.apple_rounded,
    'banana' => Icons.emoji_food_beverage_rounded,
    'book' => Icons.menu_book_rounded,
    'bag' => Icons.shopping_bag_rounded,
    'key' => Icons.key_rounded,
    'shoes' => Icons.directions_walk_rounded,
    'laptop' => Icons.laptop_mac_rounded,
    'phone' => Icons.smartphone_rounded,
    'door' => Icons.door_front_door_rounded,
    'window' => Icons.window_rounded,
    'lamp' => Icons.light_rounded,
    'bed' => Icons.bed_rounded,
    'street' => Icons.signpost_rounded,
    'shop' => Icons.storefront_rounded,
    'restaurant' => Icons.restaurant_rounded,
    'hotel' => Icons.hotel_rounded,
    'station' => Icons.train_rounded,
    'airport' => Icons.flight_rounded,
    _ => Icons.auto_awesome_rounded,
  };
}

IconData catchCategoryIcon(String category) {
  return switch (category) {
    'Cafe' => Icons.local_cafe_rounded,
    'Kitchen' => Icons.soup_kitchen_rounded,
    'Travel' => Icons.luggage_rounded,
    'Nature' => Icons.eco_rounded,
    'Home' => Icons.chair_rounded,
    'Food' => Icons.restaurant_rounded,
    _ => Icons.bookmark_rounded,
  };
}
