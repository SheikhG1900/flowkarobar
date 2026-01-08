import 'package:flutter/material.dart';

class IconHelper {
  // Mapping of keywords to related icons
  static final Map<String, List<IconData>> _keywordIcons = {
    // Food & Dining
    'food': [Icons.restaurant, Icons.lunch_dining, Icons.fastfood, Icons.local_pizza, Icons.kitchen],
    'eat': [Icons.restaurant, Icons.restaurant_menu, Icons.dinner_dining],
    'drink': [Icons.local_bar, Icons.local_cafe, Icons.wine_bar, Icons.liquor],
    'coffee': [Icons.local_cafe, Icons.coffee, Icons.coffee_maker],
    'grocer': [Icons.local_grocery_store, Icons.shopping_cart, Icons.shopping_basket, Icons.store],
    'market': [Icons.storefront, Icons.local_convenience_store],

    // Transport
    'travel': [Icons.flight, Icons.train, Icons.directions_bus, Icons.directions_car],
    'trip': [Icons.flight_takeoff, Icons.luggage, Icons.map],
    'car': [Icons.directions_car, Icons.local_taxi, Icons.car_rental, Icons.garage],
    'bus': [Icons.directions_bus, Icons.airport_shuttle],
    'fuel': [Icons.local_gas_station, Icons.ev_station],
    'bike': [Icons.directions_bike, Icons.pedal_bike, Icons.motorcycle],
    
    // Bills & Utilities
    'bill': [Icons.receipt, Icons.receipt_long, Icons.description],
    'electric': [Icons.electric_bolt, Icons.lightbulb, Icons.electrical_services],
    'water': [Icons.water_drop, Icons.plumbing],
    'internet': [Icons.wifi, Icons.router, Icons.network_check],
    'phone': [Icons.phone_android, Icons.phone_iphone, Icons.sim_card],
    'rent': [Icons.home, Icons.apartment, Icons.house],
    
    // Health & Fitness
    'health': [Icons.local_hospital, Icons.medical_services, Icons.healing],
    'doctor': [Icons.person_outline, Icons.medical_information],
    'gym': [Icons.fitness_center, Icons.sports_gymnastics],
    'sport': [Icons.sports_soccer, Icons.sports_tennis, Icons.pool],
    
    // Shopping & Entertainment
    'shop': [Icons.shopping_bag, Icons.checkroom, Icons.local_mall],
    'cloth': [Icons.checkroom, Icons.dry_cleaning],
    'movie': [Icons.movie, Icons.theaters, Icons.local_movies],
    'game': [Icons.sports_esports, Icons.videogame_asset, Icons.casino],
    
    // Income
    'salary': [Icons.account_balance_wallet, Icons.payments, Icons.attach_money],
    'wage': [Icons.work, Icons.price_check],
    'bonus': [Icons.star, Icons.card_giftcard],
    'invest': [Icons.trending_up, Icons.show_chart, Icons.currency_bitcoin],
    'gift': [Icons.card_giftcard, Icons.redeem, Icons.volunteer_activism],
    
    // Education & Work
    'school': [Icons.school, Icons.menu_book, Icons.auto_stories],
    'course': [Icons.library_books, Icons.class_],
    'work': [Icons.work, Icons.business_center, Icons.laptop_mac],
    'office': [Icons.desk, Icons.print, Icons.meeting_room],
  };

  /// Get suggested icons based on category name
  static List<IconData> getSuggestedIcons(String name) {
    if (name.isEmpty) return [];

    final normalizedName = name.toLowerCase().trim();
    final Set<IconData> suggestions = {};

    // Check for exact keyword matches and partial matches
    _keywordIcons.forEach((keyword, icons) {
      if (normalizedName.contains(keyword)) {
        suggestions.addAll(icons);
      }
    });

    return suggestions.toList();
  }
}

