import 'package:flutter/material.dart';

class IconHelper {
  /// Comprehensive list of icons available for categories
  static final List<IconData> allIcons = [
    // --- Finance & Money ---
    Icons.attach_money, Icons.money_off, Icons.account_balance,
    Icons.account_balance_wallet,
    Icons.savings, Icons.credit_card, Icons.currency_bitcoin,
    Icons.currency_exchange,
    Icons.currency_pound, Icons.currency_yen, Icons.currency_rupee, Icons.euro,
    Icons.paid, Icons.payments, Icons.price_check, Icons.price_change,
    Icons.receipt, Icons.receipt_long, Icons.request_quote, Icons.wallet,
    Icons.trending_up, Icons.trending_down, Icons.show_chart, Icons.pie_chart,
    Icons.bar_chart, Icons.stacked_line_chart, Icons.query_stats,
    Icons.timeline,
    Icons.calculate, Icons.percent, Icons.money, Icons.monetization_on,

    // --- Food & Drink ---
    Icons.restaurant, Icons.restaurant_menu, Icons.lunch_dining,
    Icons.dinner_dining,
    Icons.breakfast_dining, Icons.brunch_dining, Icons.ramen_dining,
    Icons.local_pizza, Icons.local_cafe, Icons.coffee, Icons.coffee_maker,
    Icons.fastfood, Icons.tapas, Icons.soup_kitchen, Icons.bakery_dining,
    Icons.cake, Icons.icecream, Icons.liquor, Icons.local_bar,
    Icons.wine_bar, Icons.nightlife, Icons.sports_bar, Icons.kitchen,
    Icons.bento, Icons.rice_bowl, Icons.kebab_dining, Icons.takeout_dining,
    Icons.egg, Icons.egg_alt, Icons.set_meal,

    // --- Shopping ---
    Icons.shopping_bag, Icons.shopping_cart, Icons.shopping_basket, Icons.store,
    Icons.storefront, Icons.local_grocery_store, Icons.local_convenience_store,
    Icons.local_mall,
    Icons.checkroom, Icons.diamond, Icons.watch,
    Icons.card_giftcard, Icons.redeem, Icons.loyalty, Icons.sell,
    Icons.qr_code, Icons.qr_code_scanner, Icons.barcode_reader, Icons.label,
    Icons.production_quantity_limits, Icons.inventory_2, Icons.shop,
    Icons.shop_two,

    // --- Transport ---
    Icons.directions_car, Icons.car_rental, Icons.local_taxi,
    Icons.airport_shuttle,
    Icons.directions_bus, Icons.bus_alert, Icons.directions_subway, Icons.train,
    Icons.tram, Icons.directions_railway, Icons.flight, Icons.flight_takeoff,
    Icons.flight_land, Icons.airlines, Icons.directions_boat, Icons.sailing,
    Icons.directions_bike, Icons.pedal_bike, Icons.moped, Icons.motorcycle,
    Icons.electric_scooter, Icons.ev_station, Icons.local_gas_station,
    Icons.oil_barrel,
    Icons.tire_repair, Icons.car_repair, Icons.local_parking, Icons.garage,
    Icons.commute, Icons.navigation, Icons.map, Icons.wrong_location,

    // --- Home & Living ---
    Icons.home, Icons.house, Icons.apartment, Icons.cottage,
    Icons.holiday_village, Icons.villa, Icons.gite, Icons.bungalow,
    Icons.roofing, Icons.foundation, Icons.balcony, Icons.fence,
    Icons.door_sliding, Icons.window, Icons.chair, Icons.bed,
    Icons.weekend, Icons.table_restaurant, Icons.light, Icons.lightbulb,
    Icons.highlight, Icons.flashlight_on, Icons.curtains,
    Icons.blinds, Icons.kitchen, Icons.microwave, Icons.blender,
    Icons.coffee_maker, Icons.flatware, Icons.dry_cleaning, Icons.iron,
    Icons.wash, Icons.local_laundry_service, Icons.cleaning_services,
    Icons.soap,

    // --- Utilities & Bills ---
    Icons.water_drop, Icons.water_damage, Icons.water, Icons.opacity,
    Icons.electric_bolt, Icons.electrical_services, Icons.bolt, Icons.power,
    Icons.power_settings_new, Icons.wifi, Icons.router, Icons.network_check,
    Icons.cell_tower, Icons.signal_cellular_alt, Icons.sim_card,
    Icons.phone_android,
    Icons.phone_iphone, Icons.smartphone, Icons.tablet_mac, Icons.laptop_mac,
    Icons.desktop_windows, Icons.tv, Icons.connected_tv, Icons.speaker,
    Icons.headphones, Icons.battery_charging_full, Icons.propane,
    Icons.heat_pump,

    // --- Health & Fitness ---
    Icons.favorite, Icons.health_and_safety, Icons.local_hospital,
    Icons.medical_services,
    Icons.medical_information, Icons.emergency, Icons.healing, Icons.medication,
    Icons.vaccines, Icons.bloodtype, Icons.monitor_heart, Icons.heart_broken,
    Icons.psychology, Icons.fitness_center, Icons.sports_gymnastics,
    Icons.directions_run,
    Icons.directions_walk, Icons.pool, Icons.sports_soccer,
    Icons.sports_basketball,
    Icons.sports_tennis, Icons.sports_volleyball, Icons.sports_golf,
    Icons.sports_cricket,
    Icons.sports_baseball, Icons.sports_football, Icons.sports_hockey,
    Icons.sports_motorsports,
    Icons.sports_martial_arts, Icons.snowboarding, Icons.kayaking,
    Icons.surfing,
    Icons.spa, Icons.self_improvement, Icons.face, Icons.mood,

    // --- Education & Work ---
    Icons.school, Icons.history_edu, Icons.menu_book, Icons.auto_stories,
    Icons.import_contacts, Icons.library_books, Icons.class_, Icons.assignment,
    Icons.edit_note, Icons.notes, Icons.bookmark, Icons.backpack,
    Icons.science, Icons.biotech, Icons.architecture, Icons.construction,
    Icons.engineering, Icons.handyman, Icons.build, Icons.plumbing,
    Icons.work, Icons.work_history, Icons.business_center, Icons.cases,
    Icons.meeting_room, Icons.groups, Icons.co_present, Icons.badge,
    Icons.verified_user, Icons.admin_panel_settings, Icons.gavel, Icons.balance,

    // --- Entertainment & Leisure ---
    Icons.movie, Icons.theaters, Icons.live_tv, Icons.theater_comedy,
    Icons.music_note, Icons.music_video, Icons.lyrics, Icons.mic,
    Icons.piano, Icons.queue_music, Icons.album, Icons.headset,
    Icons.sports_esports, Icons.videogame_asset, Icons.gamepad, Icons.toys,
    Icons.casino, Icons.extension, Icons.palette, Icons.brush,
    Icons.draw, Icons.camera_alt, Icons.photo_camera, Icons.collections,
    Icons.edit, Icons.auto_fix_high, Icons.celebration, Icons.cake,
    Icons.festival, Icons.stadium, Icons.attractions, Icons.park,

    // --- Nature & Animals ---
    Icons.pets, Icons.cruelty_free, Icons.nature, Icons.nature_people,
    Icons.forest, Icons.landscape, Icons.terrain, Icons.volcano,
    Icons.water, Icons.sunny, Icons.wb_sunny, Icons.bedtime,
    Icons.cloud, Icons.thunderstorm, Icons.ac_unit, Icons.air,
    Icons.tsunami, Icons.cyclone, Icons.flood, Icons.severe_cold,

    // --- Other / Misc ---
    Icons.category, Icons.dashboard, Icons.widgets, Icons.apps,
    Icons.list, Icons.view_list, Icons.grid_view, Icons.check_circle,
    Icons.info, Icons.help, Icons.error, Icons.warning,
    Icons.add_circle, Icons.remove_circle, Icons.cancel, Icons.delete,
    Icons.star, Icons.star_border, Icons.thumb_up, Icons.thumb_down,
    Icons.favorite_border, Icons.send, Icons.mail, Icons.chat,
    Icons.notifications, Icons.event, Icons.calendar_today, Icons.schedule,
    Icons.timer, Icons.lock, Icons.key, Icons.security,
  ];

  // Mapping of keywords to related icons
  static final Map<String, List<IconData>> _keywordIcons = {
    // Food & Dining
    'food': [
      Icons.restaurant,
      Icons.lunch_dining,
      Icons.fastfood,
      Icons.local_pizza,
      Icons.kitchen,
      Icons.bento,
      Icons.set_meal
    ],
    'eat': [
      Icons.restaurant,
      Icons.restaurant_menu,
      Icons.dinner_dining,
      Icons.breakfast_dining
    ],
    'drink': [
      Icons.local_bar,
      Icons.local_cafe,
      Icons.wine_bar,
      Icons.liquor,
      Icons.water_drop
    ],
    'coffee': [Icons.local_cafe, Icons.coffee, Icons.coffee_maker],
    'grocer': [
      Icons.local_grocery_store,
      Icons.shopping_cart,
      Icons.shopping_basket,
      Icons.store
    ],
    'market': [Icons.storefront, Icons.local_convenience_store],
    'snack': [Icons.icecream, Icons.cake, Icons.cookie],

    // Transport
    'travel': [
      Icons.flight,
      Icons.train,
      Icons.directions_bus,
      Icons.directions_car,
      Icons.luggage
    ],
    'trip': [Icons.flight_takeoff, Icons.luggage, Icons.map, Icons.navigation],
    'car': [
      Icons.directions_car,
      Icons.local_taxi,
      Icons.car_rental,
      Icons.garage,
      Icons.local_gas_station,
      Icons.oil_barrel,
      Icons.car_repair
    ],
    'bus': [Icons.directions_bus, Icons.airport_shuttle, Icons.bus_alert],
    'fuel': [Icons.local_gas_station, Icons.ev_station, Icons.propane],
    'bike': [
      Icons.directions_bike,
      Icons.pedal_bike,
      Icons.motorcycle,
      Icons.moped
    ],
    'train': [
      Icons.train,
      Icons.directions_subway,
      Icons.tram,
      Icons.directions_railway
    ],

    // Bills & Utilities
    'bill': [
      Icons.receipt,
      Icons.receipt_long,
      Icons.description,
      Icons.request_quote
    ],
    'electric': [
      Icons.electric_bolt,
      Icons.lightbulb,
      Icons.electrical_services,
      Icons.bolt,
      Icons.power
    ],
    'water': [
      Icons.water_drop,
      Icons.plumbing,
      Icons.water_damage,
      Icons.shower
    ],
    'internet': [
      Icons.wifi,
      Icons.router,
      Icons.network_check,
      Icons.cell_tower
    ],
    'phone': [
      Icons.phone_android,
      Icons.phone_iphone,
      Icons.sim_card,
      Icons.smartphone
    ],
    'rent': [Icons.home, Icons.apartment, Icons.house, Icons.key],
    'gas': [Icons.propane, Icons.heat_pump, Icons.local_gas_station],

    // Health & Fitness
    'health': [
      Icons.local_hospital,
      Icons.medical_services,
      Icons.healing,
      Icons.health_and_safety,
      Icons.monitor_heart
    ],
    'doctor': [
      Icons.person_outline,
      Icons.medical_information,
      Icons.emergency
    ],
    'gym': [
      Icons.fitness_center,
      Icons.sports_gymnastics,
      Icons.directions_run
    ],
    'sport': [
      Icons.sports_soccer,
      Icons.sports_tennis,
      Icons.pool,
      Icons.sports_basketball
    ],
    'med': [Icons.medication, Icons.vaccines, Icons.local_pharmacy],

    // Shopping & Entertainment
    'shop': [
      Icons.shopping_bag,
      Icons.checkroom,
      Icons.local_mall,
      Icons.storefront,
      Icons.loyalty
    ],
    'cloth': [Icons.checkroom, Icons.dry_cleaning, Icons.iron],
    'movie': [Icons.movie, Icons.theaters, Icons.local_movies, Icons.live_tv],
    'game': [
      Icons.sports_esports,
      Icons.videogame_asset,
      Icons.casino,
      Icons.toys
    ],
    'music': [
      Icons.music_note,
      Icons.headphones,
      Icons.speaker,
      Icons.piano,
      Icons.mic
    ],
    'fun': [Icons.celebration, Icons.festival, Icons.attractions, Icons.park],

    // Income
    'salary': [
      Icons.account_balance_wallet,
      Icons.payments,
      Icons.attach_money,
      Icons.work
    ],
    'wage': [Icons.work, Icons.price_check, Icons.money],
    'bonus': [Icons.star, Icons.card_giftcard, Icons.savings],
    'invest': [
      Icons.trending_up,
      Icons.show_chart,
      Icons.currency_bitcoin,
      Icons.stacked_line_chart
    ],
    'gift': [
      Icons.card_giftcard,
      Icons.redeem,
      Icons.volunteer_activism,
      Icons.inventory_2
    ],

    // Education & Work
    'school': [
      Icons.school,
      Icons.menu_book,
      Icons.auto_stories,
      Icons.backpack
    ],
    'course': [Icons.library_books, Icons.class_, Icons.assignment],
    'work': [
      Icons.work,
      Icons.business_center,
      Icons.laptop_mac,
      Icons.work_history
    ],
    'office': [Icons.desk, Icons.print, Icons.meeting_room, Icons.groups],

    // Home
    'home': [
      Icons.home,
      Icons.cottage,
      Icons.cleaning_services,
      Icons.chair,
      Icons.bed
    ],
    'repair': [
      Icons.handyman,
      Icons.build,
      Icons.construction,
      Icons.home_repair_service
    ],
    'clean': [
      Icons.cleaning_services,
      Icons.wash,
      Icons.local_laundry_service,
      Icons.soap
    ],
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
