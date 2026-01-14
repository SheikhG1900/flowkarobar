import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class IconHelper {
  /// Comprehensive list of icons available for categories
  static final List<IconData> allIcons = [
    // --- Finance & Money ---
    Symbols.attach_money, Symbols.money_off, Symbols.account_balance,
    Symbols.account_balance_wallet,
    Symbols.savings, Symbols.credit_card, Symbols.currency_bitcoin,
    Symbols.currency_exchange,
    Symbols.currency_pound, Symbols.currency_yen, Symbols.currency_rupee,
    Symbols.euro,
    Symbols.paid, Symbols.payments, Symbols.price_check, Symbols.price_change,
    Symbols.receipt, Symbols.receipt_long, Symbols.request_quote,
    Symbols.wallet,
    Symbols.trending_up, Symbols.trending_down, Symbols.show_chart,
    Symbols.pie_chart,
    Symbols.bar_chart, Symbols.stacked_line_chart, Symbols.query_stats,
    Symbols.timeline,
    Symbols.calculate, Symbols.percent, Symbols.money, Symbols.monetization_on,

    // --- Food & Drink ---
    Symbols.restaurant, Symbols.restaurant_menu, Symbols.lunch_dining,
    Symbols.dinner_dining,
    Symbols.breakfast_dining, Symbols.brunch_dining, Symbols.ramen_dining,
    Symbols.local_pizza, Symbols.local_cafe, Symbols.coffee,
    Symbols.coffee_maker,
    Symbols.fastfood, Symbols.tapas, Symbols.soup_kitchen,
    Symbols.bakery_dining,
    Symbols.cake, Symbols.icecream, Symbols.liquor, Symbols.local_bar,
    Symbols.wine_bar, Symbols.nightlife, Symbols.sports_bar, Symbols.kitchen,
    Symbols.bento, Symbols.rice_bowl, Symbols.kebab_dining,
    Symbols.takeout_dining,
    Symbols.egg, Symbols.egg_alt, Symbols.set_meal,

    // --- Shopping ---
    Symbols.shopping_bag, Symbols.shopping_cart, Symbols.shopping_basket,
    Symbols.store,
    Symbols.storefront, Symbols.local_grocery_store,
    Symbols.local_convenience_store,
    Symbols.local_mall,
    Symbols.checkroom, Symbols.diamond, Symbols.watch,
    Symbols.card_giftcard, Symbols.redeem, Symbols.loyalty, Symbols.sell,
    Symbols.qr_code, Symbols.qr_code_scanner, Symbols.barcode_reader,
    Symbols.label,
    Symbols.production_quantity_limits, Symbols.inventory_2, Symbols.shop,
    Symbols.shop_two,

    // --- Transport ---
    Symbols.directions_car, Symbols.car_rental, Symbols.local_taxi,
    Symbols.airport_shuttle,
    Symbols.directions_bus, Symbols.bus_alert, Symbols.directions_subway,
    Symbols.train,
    Symbols.tram, Symbols.directions_railway, Symbols.flight,
    Symbols.flight_takeoff,
    Symbols.flight_land, Symbols.airlines, Symbols.directions_boat,
    Symbols.sailing,
    Symbols.directions_bike, Symbols.pedal_bike, Symbols.moped,
    Symbols.motorcycle,
    Symbols.electric_scooter, Symbols.ev_station, Symbols.local_gas_station,
    Symbols.oil_barrel,
    Symbols.tire_repair, Symbols.car_repair, Symbols.local_parking,
    Symbols.garage,
    Symbols.commute, Symbols.navigation, Symbols.map, Symbols.wrong_location,

    // --- Home & Living ---
    Symbols.home, Symbols.house, Symbols.apartment, Symbols.cottage,
    Symbols.holiday_village, Symbols.villa, Symbols.gite, Symbols.bungalow,
    Symbols.roofing, Symbols.foundation, Symbols.balcony, Symbols.fence,
    Symbols.door_sliding, Symbols.window, Symbols.chair, Symbols.bed,
    Symbols.weekend, Symbols.table_restaurant, Symbols.light, Symbols.lightbulb,
    Symbols.highlight, Symbols.flashlight_on, Symbols.curtains,
    Symbols.blinds, Symbols.kitchen, Symbols.microwave, Symbols.blender,
    Symbols.coffee_maker, Symbols.flatware, Symbols.dry_cleaning, Symbols.iron,
    Symbols.wash, Symbols.local_laundry_service, Symbols.cleaning_services,
    Symbols.soap,

    // --- Utilities & Bills ---
    Symbols.water_drop, Symbols.water_damage, Symbols.water, Symbols.opacity,
    Symbols.electric_bolt, Symbols.electrical_services, Symbols.bolt,
    Symbols.power,
    Symbols.power_settings_new, Symbols.wifi, Symbols.router,
    Symbols.network_check,
    Symbols.cell_tower, Symbols.signal_cellular_alt, Symbols.sim_card,
    Symbols.phone_android,
    Symbols.phone_iphone, Symbols.smartphone, Symbols.tablet_mac,
    Symbols.laptop_mac,
    Symbols.desktop_windows, Symbols.tv, Symbols.connected_tv, Symbols.speaker,
    Symbols.headphones, Symbols.battery_charging_full, Symbols.propane,
    Symbols.heat_pump,

    // --- Health & Fitness ---
    Symbols.favorite, Symbols.health_and_safety, Symbols.local_hospital,
    Symbols.medical_services,
    Symbols.medical_information, Symbols.emergency, Symbols.healing,
    Symbols.medication,
    Symbols.vaccines, Symbols.bloodtype, Symbols.monitor_heart,
    Symbols.heart_broken,
    Symbols.psychology, Symbols.fitness_center, Symbols.sports_gymnastics,
    Symbols.directions_run,
    Symbols.directions_walk, Symbols.pool, Symbols.sports_soccer,
    Symbols.sports_basketball,
    Symbols.sports_tennis, Symbols.sports_volleyball, Symbols.sports_golf,
    Symbols.sports_cricket,
    Symbols.sports_baseball, Symbols.sports_football, Symbols.sports_hockey,
    Symbols.sports_motorsports,
    Symbols.sports_martial_arts, Symbols.snowboarding, Symbols.kayaking,
    Symbols.surfing,
    Symbols.spa, Symbols.self_improvement, Symbols.face, Symbols.mood,

    // --- Education & Work ---
    Symbols.school, Symbols.history_edu, Symbols.menu_book,
    Symbols.auto_stories,
    Symbols.import_contacts, Symbols.library_books, Symbols.class_,
    Symbols.assignment,
    Symbols.edit_note, Symbols.notes, Symbols.bookmark, Symbols.backpack,
    Symbols.science, Symbols.biotech, Symbols.architecture,
    Symbols.construction,
    Symbols.engineering, Symbols.handyman, Symbols.build, Symbols.plumbing,
    Symbols.work, Symbols.work_history, Symbols.business_center, Symbols.cases,
    Symbols.meeting_room, Symbols.groups, Symbols.co_present, Symbols.badge,
    Symbols.verified_user, Symbols.admin_panel_settings, Symbols.gavel,
    Symbols.balance,

    // --- Entertainment & Leisure ---
    Symbols.movie, Symbols.theaters, Symbols.live_tv, Symbols.theater_comedy,
    Symbols.music_note, Symbols.music_video, Symbols.lyrics, Symbols.mic,
    Symbols.piano, Symbols.queue_music, Symbols.album, Symbols.headset,
    Symbols.sports_esports, Symbols.videogame_asset, Symbols.gamepad,
    Symbols.toys,
    Symbols.casino, Symbols.extension, Symbols.palette, Symbols.brush,
    Symbols.draw, Symbols.camera_alt, Symbols.photo_camera, Symbols.collections,
    Symbols.edit, Symbols.auto_fix_high, Symbols.celebration, Symbols.cake,
    Symbols.festival, Symbols.stadium, Symbols.attractions, Symbols.park,

    // --- Nature & Animals ---
    Symbols.pets, Symbols.cruelty_free, Symbols.nature, Symbols.nature_people,
    Symbols.forest, Symbols.landscape, Symbols.terrain, Symbols.volcano,
    Symbols.water, Symbols.sunny, Symbols.wb_sunny, Symbols.bedtime,
    Symbols.cloud, Symbols.thunderstorm, Symbols.ac_unit, Symbols.air,
    Symbols.tsunami, Symbols.cyclone, Symbols.flood, Symbols.severe_cold,

    // --- Other / Misc ---
    Symbols.category, Symbols.dashboard, Symbols.widgets, Symbols.apps,
    Symbols.list, Symbols.view_list, Symbols.grid_view, Symbols.check_circle,
    Symbols.info, Symbols.help, Symbols.error, Symbols.warning,
    Symbols.add_circle, Symbols.remove_circle, Symbols.cancel, Symbols.delete,
    Symbols.star, Symbols.star_border, Symbols.thumb_up, Symbols.thumb_down,
    Symbols.favorite_border, Symbols.send, Symbols.mail, Symbols.chat,
    Symbols.notifications, Symbols.event, Symbols.calendar_today,
    Symbols.schedule,
    Symbols.timer, Symbols.lock, Symbols.key, Symbols.security,
  ];

  // Mapping of keywords to related icons
  static final Map<String, List<IconData>> _keywordIcons = {
    // Food & Dining
    'food': [
      Symbols.restaurant,
      Symbols.lunch_dining,
      Symbols.fastfood,
      Symbols.local_pizza,
      Symbols.kitchen,
      Symbols.bento,
      Symbols.set_meal
    ],
    'eat': [
      Symbols.restaurant,
      Symbols.restaurant_menu,
      Symbols.dinner_dining,
      Symbols.breakfast_dining
    ],
    'drink': [
      Symbols.local_bar,
      Symbols.local_cafe,
      Symbols.wine_bar,
      Symbols.liquor,
      Symbols.water_drop
    ],
    'coffee': [Symbols.local_cafe, Symbols.coffee, Symbols.coffee_maker],
    'grocer': [
      Symbols.local_grocery_store,
      Symbols.shopping_cart,
      Symbols.shopping_basket,
      Symbols.store
    ],
    'market': [Symbols.storefront, Symbols.local_convenience_store],
    'snack': [Symbols.icecream, Symbols.cake, Symbols.cookie],

    // Transport
    'travel': [
      Symbols.flight,
      Symbols.train,
      Symbols.directions_bus,
      Symbols.directions_car,
      Symbols.luggage
    ],
    'trip': [
      Symbols.flight_takeoff,
      Symbols.luggage,
      Symbols.map,
      Symbols.navigation
    ],
    'car': [
      Symbols.directions_car,
      Symbols.local_taxi,
      Symbols.car_rental,
      Symbols.garage,
      Symbols.local_gas_station,
      Symbols.oil_barrel,
      Symbols.car_repair
    ],
    'bus': [Symbols.directions_bus, Symbols.airport_shuttle, Symbols.bus_alert],
    'fuel': [Symbols.local_gas_station, Symbols.ev_station, Symbols.propane],
    'bike': [
      Symbols.directions_bike,
      Symbols.pedal_bike,
      Symbols.motorcycle,
      Symbols.moped
    ],
    'train': [
      Symbols.train,
      Symbols.directions_subway,
      Symbols.tram,
      Symbols.directions_railway
    ],

    // Bills & Utilities
    'bill': [
      Symbols.receipt,
      Symbols.receipt_long,
      Symbols.description,
      Symbols.request_quote
    ],
    'electric': [
      Symbols.electric_bolt,
      Symbols.lightbulb,
      Symbols.electrical_services,
      Symbols.bolt,
      Symbols.power
    ],
    'water': [
      Symbols.water_drop,
      Symbols.plumbing,
      Symbols.water_damage,
      Symbols.shower
    ],
    'internet': [
      Symbols.wifi,
      Symbols.router,
      Symbols.network_check,
      Symbols.cell_tower
    ],
    'phone': [
      Symbols.phone_android,
      Symbols.phone_iphone,
      Symbols.sim_card,
      Symbols.smartphone
    ],
    'rent': [Symbols.home, Symbols.apartment, Symbols.house, Symbols.key],
    'gas': [Symbols.propane, Symbols.heat_pump, Symbols.local_gas_station],

    // Health & Fitness
    'health': [
      Symbols.local_hospital,
      Symbols.medical_services,
      Symbols.healing,
      Symbols.health_and_safety,
      Symbols.monitor_heart
    ],
    'doctor': [
      Symbols.person_outline,
      Symbols.medical_information,
      Symbols.emergency
    ],
    'gym': [
      Symbols.fitness_center,
      Symbols.sports_gymnastics,
      Symbols.directions_run
    ],
    'sport': [
      Symbols.sports_soccer,
      Symbols.sports_tennis,
      Symbols.pool,
      Symbols.sports_basketball
    ],
    'med': [Symbols.medication, Symbols.vaccines, Symbols.local_pharmacy],

    // Shopping & Entertainment
    'shop': [
      Symbols.shopping_bag,
      Symbols.checkroom,
      Symbols.local_mall,
      Symbols.storefront,
      Symbols.loyalty
    ],
    'cloth': [Symbols.checkroom, Symbols.dry_cleaning, Symbols.iron],
    'movie': [
      Symbols.movie,
      Symbols.theaters,
      Symbols.local_movies,
      Symbols.live_tv
    ],
    'game': [
      Symbols.sports_esports,
      Symbols.videogame_asset,
      Symbols.casino,
      Symbols.toys
    ],
    'music': [
      Symbols.music_note,
      Symbols.headphones,
      Symbols.speaker,
      Symbols.piano,
      Symbols.mic
    ],
    'fun': [
      Symbols.celebration,
      Symbols.festival,
      Symbols.attractions,
      Symbols.park
    ],

    // Income
    'salary': [
      Symbols.account_balance_wallet,
      Symbols.payments,
      Symbols.attach_money,
      Symbols.work
    ],
    'wage': [Symbols.work, Symbols.price_check, Symbols.money],
    'bonus': [Symbols.star, Symbols.card_giftcard, Symbols.savings],
    'invest': [
      Symbols.trending_up,
      Symbols.show_chart,
      Symbols.currency_bitcoin,
      Symbols.stacked_line_chart
    ],
    'gift': [
      Symbols.card_giftcard,
      Symbols.redeem,
      Symbols.volunteer_activism,
      Symbols.inventory_2
    ],

    // Education & Work
    'school': [
      Symbols.school,
      Symbols.menu_book,
      Symbols.auto_stories,
      Symbols.backpack
    ],
    'course': [Symbols.library_books, Symbols.class_, Symbols.assignment],
    'work': [
      Symbols.work,
      Symbols.business_center,
      Symbols.laptop_mac,
      Symbols.work_history
    ],
    'office': [
      Symbols.desk,
      Symbols.print,
      Symbols.meeting_room,
      Symbols.groups
    ],

    // Home
    'home': [
      Symbols.home,
      Symbols.cottage,
      Symbols.cleaning_services,
      Symbols.chair,
      Symbols.bed
    ],
    'repair': [
      Symbols.handyman,
      Symbols.build,
      Symbols.construction,
      Symbols.home_repair_service
    ],
    'clean': [
      Symbols.cleaning_services,
      Symbols.wash,
      Symbols.local_laundry_service,
      Symbols.soap
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

  /// Converts a codePoint string to IconData
  /// Returns null if the string is null, empty, or cannot be parsed
  static IconData? getIconData(String? codePointString) {
    if (codePointString == null || codePointString.isEmpty) {
      return null;
    }

    final codePoint = int.tryParse(codePointString);
    if (codePoint != null) {
      return IconData(
        codePoint,
        fontFamily: 'MaterialSymbolsOutlined',
        fontPackage: 'material_symbols_icons',
      );
    }

    return null;
  }
}
