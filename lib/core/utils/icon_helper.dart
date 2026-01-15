import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class IconHelper {
  /// Comprehensive list of icons available for categories
  static final List<IconData> _iconList = [
    // --- Finance & Money ---
    Symbols.attach_money, Symbols.account_balance,
    Symbols.account_balance_wallet,
    Symbols.savings, Symbols.credit_card, Symbols.currency_bitcoin,
    Symbols.currency_exchange,
    Symbols.currency_pound, Symbols.currency_yen, Symbols.currency_rupee,
    Symbols.euro,
    Symbols.payments,
    Symbols.receipt, Symbols.receipt_long,
    Symbols.trending_up, Symbols.trending_down, Symbols.show_chart,
    Symbols.bar_chart, Symbols.query_stats,
    Symbols.timeline,
    Symbols.calculate, Symbols.percent, Symbols.money, Symbols.monetization_on,

    // --- Food & Drink ---
    Symbols.restaurant, Symbols.restaurant_menu, Symbols.lunch_dining,
    Symbols.dinner_dining,
    Symbols.breakfast_dining, Symbols.brunch_dining, Symbols.ramen_dining,
    Symbols.local_pizza, Symbols.local_cafe, Symbols.coffee,
    Symbols.coffee_maker,
    Symbols.fastfood, Symbols.soup_kitchen,
    Symbols.bakery_dining,
    Symbols.cake, Symbols.icecream, Symbols.liquor, Symbols.local_bar,
    Symbols.nightlife, Symbols.kitchen,
    Symbols.kebab_dining,
    Symbols.takeout_dining,
    Symbols.egg, Symbols.egg_alt,

    // --- Shopping ---
    Symbols.shopping_cart, Symbols.shopping_basket,
    Symbols.store,
    Symbols.storefront, Symbols.local_grocery_store,
    Symbols.local_convenience_store,
    Symbols.local_mall,
    Symbols.diamond, Symbols.watch,
    Symbols.card_giftcard, Symbols.redeem, Symbols.loyalty,
    Symbols.qr_code,
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
    Symbols.commute, Symbols.navigation, Symbols.map, Symbols.wrong_location,

    // --- Home & Living ---
    Symbols.home, Symbols.house, Symbols.apartment, Symbols.cottage,
    Symbols.holiday_village, Symbols.villa, Symbols.gite, Symbols.bungalow,
    Symbols.balcony,
    Symbols.door_sliding, Symbols.chair, Symbols.bed,
    Symbols.weekend, Symbols.table_restaurant, Symbols.lightbulb,
    Symbols.highlight, Symbols.curtains,
    Symbols.blinds, Symbols.kitchen, Symbols.blender,
    Symbols.coffee_maker, Symbols.dry_cleaning, Symbols.iron,
    Symbols.local_laundry_service,

    // --- Utilities & Bills ---
    Symbols.water_drop, Symbols.opacity,
    Symbols.electric_bolt, Symbols.bolt,
    Symbols.power,
    Symbols.wifi, Symbols.router,
    Symbols.network_check,
    Symbols.cell_tower, Symbols.signal_cellular_alt, Symbols.sim_card,
    Symbols.smartphone, Symbols.tablet_mac,
    Symbols.laptop_mac,
    Symbols.desktop_windows, Symbols.tv, Symbols.connected_tv, Symbols.speaker,
    Symbols.headphones, Symbols.battery_charging_full, Symbols.propane,
    Symbols.heat_pump,

    // --- Health & Fitness ---
    Symbols.favorite, Symbols.health_and_safety, Symbols.local_hospital,
    Symbols.medical_information, Symbols.emergency, Symbols.healing,
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
    Symbols.spa, Symbols.self_improvement, Symbols.mood,

    // --- Education & Work ---
    Symbols.school, Symbols.history_edu, Symbols.menu_book,
    Symbols.auto_stories,
    Symbols.import_contacts, Symbols.library_books, Symbols.class_,
    Symbols.assignment,
    Symbols.edit_note, Symbols.notes, Symbols.bookmark,
    Symbols.science, Symbols.biotech, Symbols.architecture,
    Symbols.construction,
    Symbols.engineering,
    Symbols.work, Symbols.work_history, Symbols.business_center, Symbols.cases,
    Symbols.meeting_room, Symbols.co_present, Symbols.badge,
    Symbols.admin_panel_settings, Symbols.gavel,
    Symbols.balance,

    // --- Entertainment & Leisure ---
    Symbols.movie, Symbols.theaters, Symbols.live_tv, Symbols.theater_comedy,
    Symbols.music_note, Symbols.music_video, Symbols.lyrics, Symbols.mic,
    Symbols.piano, Symbols.queue_music, Symbols.album,
    Symbols.sports_esports, Symbols.videogame_asset, Symbols.gamepad,
    Symbols.toys,
    Symbols.casino, Symbols.extension, Symbols.palette, Symbols.brush,
    Symbols.draw, Symbols.camera_alt, Symbols.photo_camera, Symbols.collections,
    Symbols.auto_fix_high, Symbols.celebration, Symbols.cake,
    Symbols.festival, Symbols.stadium, Symbols.attractions, Symbols.park,

    // --- Nature & Animals ---
    Symbols.pets, Symbols.cruelty_free, Symbols.nature, Symbols.nature_people,
    Symbols.forest, Symbols.landscape, Symbols.terrain, Symbols.volcano,
    Symbols.sunny, Symbols.wb_sunny,
    Symbols.thunderstorm, Symbols.ac_unit, Symbols.air,
    Symbols.tsunami, Symbols.cyclone, Symbols.flood, Symbols.severe_cold,

    // --- Other / Misc ---
    Symbols.category, Symbols.dashboard, Symbols.widgets, Symbols.apps,
    Symbols.list, Symbols.view_list, Symbols.grid_view,
    Symbols.info, Symbols.help,
    Symbols.add_circle, Symbols.cancel, Symbols.delete,
    Symbols.star,
    Symbols.favorite_border, Symbols.send, Symbols.mail, Symbols.chat,
    Symbols.notifications, Symbols.event, Symbols.calendar_today,
    Symbols.schedule,
    Symbols.timer, Symbols.lock, Symbols.key, Symbols.security,
  ];

  /// Dictionary of all icons with codepoints as keys for efficient lookup
  static final Map<int, IconData> allIconsMap = {
    for (var icon in _iconList) icon.codePoint: icon
  };

  /// Mapping of codePoint to glyph name (icon identifier)
  static final Map<int, String> _iconGlyphMap = {
    // --- Finance & Money ---
    Symbols.attach_money.codePoint: 'attach_money',
    Symbols.account_balance.codePoint: 'account_balance',
    Symbols.account_balance_wallet.codePoint: 'account_balance_wallet',
    Symbols.savings.codePoint: 'savings',
    Symbols.credit_card.codePoint: 'credit_card',
    Symbols.currency_bitcoin.codePoint: 'currency_bitcoin',
    Symbols.currency_exchange.codePoint: 'currency_exchange',
    Symbols.currency_pound.codePoint: 'currency_pound',
    Symbols.currency_yen.codePoint: 'currency_yen',
    Symbols.currency_rupee.codePoint: 'currency_rupee',
    Symbols.euro.codePoint: 'euro',
    Symbols.payments.codePoint: 'payments',
    Symbols.receipt.codePoint: 'receipt',
    Symbols.receipt_long.codePoint: 'receipt_long',
    Symbols.trending_up.codePoint: 'trending_up',
    Symbols.trending_down.codePoint: 'trending_down',
    Symbols.show_chart.codePoint: 'show_chart',
    Symbols.bar_chart.codePoint: 'bar_chart',
    Symbols.query_stats.codePoint: 'query_stats',
    Symbols.timeline.codePoint: 'timeline',
    Symbols.calculate.codePoint: 'calculate',
    Symbols.percent.codePoint: 'percent',
    Symbols.money.codePoint: 'money',
    Symbols.monetization_on.codePoint: 'monetization_on',

    // --- Food & Drink ---
    Symbols.restaurant.codePoint: 'restaurant',
    Symbols.restaurant_menu.codePoint: 'restaurant_menu',
    Symbols.lunch_dining.codePoint: 'lunch_dining',
    Symbols.dinner_dining.codePoint: 'dinner_dining',
    Symbols.breakfast_dining.codePoint: 'breakfast_dining',
    Symbols.brunch_dining.codePoint: 'brunch_dining',
    Symbols.ramen_dining.codePoint: 'ramen_dining',
    Symbols.local_pizza.codePoint: 'local_pizza',
    Symbols.local_cafe.codePoint: 'local_cafe',
    Symbols.coffee.codePoint: 'coffee',
    Symbols.coffee_maker.codePoint: 'coffee_maker',
    Symbols.fastfood.codePoint: 'fastfood',
    Symbols.soup_kitchen.codePoint: 'soup_kitchen',
    Symbols.bakery_dining.codePoint: 'bakery_dining',
    Symbols.cake.codePoint: 'cake',
    Symbols.icecream.codePoint: 'icecream',
    Symbols.liquor.codePoint: 'liquor',
    Symbols.local_bar.codePoint: 'local_bar',
    Symbols.nightlife.codePoint: 'nightlife',
    Symbols.kitchen.codePoint: 'kitchen',
    Symbols.kebab_dining.codePoint: 'kebab_dining',
    Symbols.takeout_dining.codePoint: 'takeout_dining',
    Symbols.egg.codePoint: 'egg',
    Symbols.egg_alt.codePoint: 'egg_alt',

    // --- Shopping ---
    Symbols.shopping_cart.codePoint: 'shopping_cart',
    Symbols.shopping_basket.codePoint: 'shopping_basket',
    Symbols.store.codePoint: 'store',
    Symbols.storefront.codePoint: 'storefront',
    Symbols.local_grocery_store.codePoint: 'local_grocery_store',
    Symbols.local_convenience_store.codePoint: 'local_convenience_store',
    Symbols.local_mall.codePoint: 'local_mall',
    Symbols.diamond.codePoint: 'diamond',
    Symbols.watch.codePoint: 'watch',
    Symbols.card_giftcard.codePoint: 'card_giftcard',
    Symbols.redeem.codePoint: 'redeem',
    Symbols.loyalty.codePoint: 'loyalty',
    Symbols.qr_code.codePoint: 'qr_code',
    Symbols.label.codePoint: 'label',
    Symbols.production_quantity_limits.codePoint: 'production_quantity_limits',
    Symbols.inventory_2.codePoint: 'inventory_2',
    Symbols.shop.codePoint: 'shop',
    Symbols.shop_two.codePoint: 'shop_two',

    // --- Transport ---
    Symbols.directions_car.codePoint: 'directions_car',
    Symbols.car_rental.codePoint: 'car_rental',
    Symbols.local_taxi.codePoint: 'local_taxi',
    Symbols.airport_shuttle.codePoint: 'airport_shuttle',
    Symbols.directions_bus.codePoint: 'directions_bus',
    Symbols.bus_alert.codePoint: 'bus_alert',
    Symbols.directions_subway.codePoint: 'directions_subway',
    Symbols.train.codePoint: 'train',
    Symbols.tram.codePoint: 'tram',
    Symbols.directions_railway.codePoint: 'directions_railway',
    Symbols.flight.codePoint: 'flight',
    Symbols.flight_takeoff.codePoint: 'flight_takeoff',
    Symbols.flight_land.codePoint: 'flight_land',
    Symbols.airlines.codePoint: 'airlines',
    Symbols.directions_boat.codePoint: 'directions_boat',
    Symbols.sailing.codePoint: 'sailing',
    Symbols.directions_bike.codePoint: 'directions_bike',
    Symbols.pedal_bike.codePoint: 'pedal_bike',
    Symbols.moped.codePoint: 'moped',
    Symbols.motorcycle.codePoint: 'motorcycle',
    Symbols.electric_scooter.codePoint: 'electric_scooter',
    Symbols.ev_station.codePoint: 'ev_station',
    Symbols.local_gas_station.codePoint: 'local_gas_station',
    Symbols.oil_barrel.codePoint: 'oil_barrel',
    Symbols.tire_repair.codePoint: 'tire_repair',
    Symbols.car_repair.codePoint: 'car_repair',
    Symbols.local_parking.codePoint: 'local_parking',
    Symbols.commute.codePoint: 'commute',
    Symbols.navigation.codePoint: 'navigation',
    Symbols.map.codePoint: 'map',
    Symbols.wrong_location.codePoint: 'wrong_location',

    // --- Home & Living ---
    Symbols.home.codePoint: 'home',
    Symbols.house.codePoint: 'house',
    Symbols.apartment.codePoint: 'apartment',
    Symbols.cottage.codePoint: 'cottage',
    Symbols.holiday_village.codePoint: 'holiday_village',
    Symbols.villa.codePoint: 'villa',
    Symbols.gite.codePoint: 'gite',
    Symbols.bungalow.codePoint: 'bungalow',
    Symbols.balcony.codePoint: 'balcony',
    Symbols.door_sliding.codePoint: 'door_sliding',
    Symbols.chair.codePoint: 'chair',
    Symbols.bed.codePoint: 'bed',
    Symbols.weekend.codePoint: 'weekend',
    Symbols.table_restaurant.codePoint: 'table_restaurant',
    Symbols.lightbulb.codePoint: 'lightbulb',
    Symbols.highlight.codePoint: 'highlight',
    Symbols.curtains.codePoint: 'curtains',
    Symbols.blinds.codePoint: 'blinds',
    Symbols.blender.codePoint: 'blender',
    Symbols.dry_cleaning.codePoint: 'dry_cleaning',
    Symbols.iron.codePoint: 'iron',
    Symbols.local_laundry_service.codePoint: 'local_laundry_service',

    // --- Utilities & Bills ---
    Symbols.water_drop.codePoint: 'water_drop',
    Symbols.opacity.codePoint: 'opacity',
    Symbols.electric_bolt.codePoint: 'electric_bolt',
    Symbols.bolt.codePoint: 'bolt',
    Symbols.power.codePoint: 'power',
    Symbols.wifi.codePoint: 'wifi',
    Symbols.router.codePoint: 'router',
    Symbols.network_check.codePoint: 'network_check',
    Symbols.cell_tower.codePoint: 'cell_tower',
    Symbols.signal_cellular_alt.codePoint: 'signal_cellular_alt',
    Symbols.sim_card.codePoint: 'sim_card',
    Symbols.smartphone.codePoint: 'smartphone',
    Symbols.tablet_mac.codePoint: 'tablet_mac',
    Symbols.laptop_mac.codePoint: 'laptop_mac',
    Symbols.desktop_windows.codePoint: 'desktop_windows',
    Symbols.tv.codePoint: 'tv',
    Symbols.connected_tv.codePoint: 'connected_tv',
    Symbols.speaker.codePoint: 'speaker',
    Symbols.headphones.codePoint: 'headphones',
    Symbols.battery_charging_full.codePoint: 'battery_charging_full',
    Symbols.propane.codePoint: 'propane',
    Symbols.heat_pump.codePoint: 'heat_pump',

    // --- Health & Fitness ---
    Symbols.favorite.codePoint: 'favorite',
    Symbols.health_and_safety.codePoint: 'health_and_safety',
    Symbols.local_hospital.codePoint: 'local_hospital',
    Symbols.medical_information.codePoint: 'medical_information',
    Symbols.emergency.codePoint: 'emergency',
    Symbols.healing.codePoint: 'healing',
    Symbols.vaccines.codePoint: 'vaccines',
    Symbols.bloodtype.codePoint: 'bloodtype',
    Symbols.monitor_heart.codePoint: 'monitor_heart',
    Symbols.heart_broken.codePoint: 'heart_broken',
    Symbols.psychology.codePoint: 'psychology',
    Symbols.fitness_center.codePoint: 'fitness_center',
    Symbols.sports_gymnastics.codePoint: 'sports_gymnastics',
    Symbols.directions_run.codePoint: 'directions_run',
    Symbols.directions_walk.codePoint: 'directions_walk',
    Symbols.pool.codePoint: 'pool',
    Symbols.sports_soccer.codePoint: 'sports_soccer',
    Symbols.sports_basketball.codePoint: 'sports_basketball',
    Symbols.sports_tennis.codePoint: 'sports_tennis',
    Symbols.sports_volleyball.codePoint: 'sports_volleyball',
    Symbols.sports_golf.codePoint: 'sports_golf',
    Symbols.sports_cricket.codePoint: 'sports_cricket',
    Symbols.sports_baseball.codePoint: 'sports_baseball',
    Symbols.sports_football.codePoint: 'sports_football',
    Symbols.sports_hockey.codePoint: 'sports_hockey',
    Symbols.sports_motorsports.codePoint: 'sports_motorsports',
    Symbols.sports_martial_arts.codePoint: 'sports_martial_arts',
    Symbols.snowboarding.codePoint: 'snowboarding',
    Symbols.kayaking.codePoint: 'kayaking',
    Symbols.surfing.codePoint: 'surfing',
    Symbols.spa.codePoint: 'spa',
    Symbols.self_improvement.codePoint: 'self_improvement',
    Symbols.mood.codePoint: 'mood',

    // --- Education & Work ---
    Symbols.school.codePoint: 'school',
    Symbols.history_edu.codePoint: 'history_edu',
    Symbols.menu_book.codePoint: 'menu_book',
    Symbols.auto_stories.codePoint: 'auto_stories',
    Symbols.import_contacts.codePoint: 'import_contacts',
    Symbols.library_books.codePoint: 'library_books',
    Symbols.class_.codePoint: 'class',
    Symbols.assignment.codePoint: 'assignment',
    Symbols.edit_note.codePoint: 'edit_note',
    Symbols.notes.codePoint: 'notes',
    Symbols.bookmark.codePoint: 'bookmark',
    Symbols.science.codePoint: 'science',
    Symbols.biotech.codePoint: 'biotech',
    Symbols.architecture.codePoint: 'architecture',
    Symbols.construction.codePoint: 'construction',
    Symbols.engineering.codePoint: 'engineering',
    Symbols.work.codePoint: 'work',
    Symbols.work_history.codePoint: 'work_history',
    Symbols.business_center.codePoint: 'business_center',
    Symbols.cases.codePoint: 'cases',
    Symbols.meeting_room.codePoint: 'meeting_room',
    Symbols.co_present.codePoint: 'co_present',
    Symbols.badge.codePoint: 'badge',
    Symbols.admin_panel_settings.codePoint: 'admin_panel_settings',
    Symbols.gavel.codePoint: 'gavel',
    Symbols.balance.codePoint: 'balance',

    // --- Entertainment & Leisure ---
    Symbols.movie.codePoint: 'movie',
    Symbols.theaters.codePoint: 'theaters',
    Symbols.live_tv.codePoint: 'live_tv',
    Symbols.theater_comedy.codePoint: 'theater_comedy',
    Symbols.music_note.codePoint: 'music_note',
    Symbols.music_video.codePoint: 'music_video',
    Symbols.lyrics.codePoint: 'lyrics',
    Symbols.mic.codePoint: 'mic',
    Symbols.piano.codePoint: 'piano',
    Symbols.queue_music.codePoint: 'queue_music',
    Symbols.album.codePoint: 'album',
    Symbols.sports_esports.codePoint: 'sports_esports',
    Symbols.videogame_asset.codePoint: 'videogame_asset',
    Symbols.gamepad.codePoint: 'gamepad',
    Symbols.toys.codePoint: 'toys',
    Symbols.casino.codePoint: 'casino',
    Symbols.extension.codePoint: 'extension',
    Symbols.palette.codePoint: 'palette',
    Symbols.brush.codePoint: 'brush',
    Symbols.draw.codePoint: 'draw',
    Symbols.camera_alt.codePoint: 'camera_alt',
    Symbols.photo_camera.codePoint: 'photo_camera',
    Symbols.collections.codePoint: 'collections',
    Symbols.auto_fix_high.codePoint: 'auto_fix_high',
    Symbols.celebration.codePoint: 'celebration',
    Symbols.festival.codePoint: 'festival',
    Symbols.stadium.codePoint: 'stadium',
    Symbols.attractions.codePoint: 'attractions',
    Symbols.park.codePoint: 'park',

    // --- Nature & Animals ---
    Symbols.pets.codePoint: 'pets',
    Symbols.cruelty_free.codePoint: 'cruelty_free',
    Symbols.nature.codePoint: 'nature',
    Symbols.nature_people.codePoint: 'nature_people',
    Symbols.forest.codePoint: 'forest',
    Symbols.landscape.codePoint: 'landscape',
    Symbols.terrain.codePoint: 'terrain',
    Symbols.volcano.codePoint: 'volcano',
    Symbols.sunny.codePoint: 'sunny',
    Symbols.wb_sunny.codePoint: 'wb_sunny',
    Symbols.thunderstorm.codePoint: 'thunderstorm',
    Symbols.ac_unit.codePoint: 'ac_unit',
    Symbols.air.codePoint: 'air',
    Symbols.tsunami.codePoint: 'tsunami',
    Symbols.cyclone.codePoint: 'cyclone',
    Symbols.flood.codePoint: 'flood',
    Symbols.severe_cold.codePoint: 'severe_cold',

    // --- Other / Misc ---
    Symbols.category.codePoint: 'category',
    Symbols.dashboard.codePoint: 'dashboard',
    Symbols.widgets.codePoint: 'widgets',
    Symbols.apps.codePoint: 'apps',
    Symbols.list.codePoint: 'list',
    Symbols.view_list.codePoint: 'view_list',
    Symbols.grid_view.codePoint: 'grid_view',
    Symbols.info.codePoint: 'info',
    Symbols.help.codePoint: 'help',
    Symbols.add_circle.codePoint: 'add_circle',
    Symbols.cancel.codePoint: 'cancel',
    Symbols.delete.codePoint: 'delete',
    Symbols.star.codePoint: 'star',
    Symbols.favorite_border.codePoint: 'favorite_border',
    Symbols.send.codePoint: 'send',
    Symbols.mail.codePoint: 'mail',
    Symbols.chat.codePoint: 'chat',
    Symbols.notifications.codePoint: 'notifications',
    Symbols.event.codePoint: 'event',
    Symbols.calendar_today.codePoint: 'calendar_today',
    Symbols.schedule.codePoint: 'schedule',
    Symbols.timer.codePoint: 'timer',
    Symbols.lock.codePoint: 'lock',
    Symbols.key.codePoint: 'key',
    Symbols.security.codePoint: 'security',
  };

  /// Getter for backward compatibility - returns all icons as a list
  static List<IconData> get allIcons => allIconsMap.values.toList();

  // Mapping of keywords to related icons
  static final Map<String, List<IconData>> _keywordIcons = {
    // Food & Dining
    'food': [
      Symbols.restaurant,
      Symbols.lunch_dining,
      Symbols.fastfood,
      Symbols.local_pizza,
      Symbols.kitchen
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
    'bill': [Symbols.receipt, Symbols.receipt_long, Symbols.description],
    'electric': [
      Symbols.electric_bolt,
      Symbols.lightbulb,
      Symbols.bolt,
      Symbols.power
    ],
    'water': [Symbols.water_drop, Symbols.shower],
    'internet': [
      Symbols.wifi,
      Symbols.router,
      Symbols.network_check,
      Symbols.cell_tower
    ],
    'phone': [Symbols.sim_card, Symbols.smartphone],
    'rent': [Symbols.home, Symbols.apartment, Symbols.house, Symbols.key],
    'gas': [Symbols.propane, Symbols.heat_pump, Symbols.local_gas_station],

    // Health & Fitness
    'health': [
      Symbols.local_hospital,
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
    'med': [Symbols.vaccines, Symbols.local_pharmacy],

    // Shopping & Entertainment
    'shop': [Symbols.local_mall, Symbols.storefront, Symbols.loyalty],
    'cloth': [Symbols.dry_cleaning, Symbols.iron],
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
    'wage': [Symbols.work, Symbols.money],
    'bonus': [Symbols.star, Symbols.card_giftcard, Symbols.savings],
    'invest': [
      Symbols.trending_up,
      Symbols.show_chart,
      Symbols.currency_bitcoin
    ],
    'gift': [
      Symbols.card_giftcard,
      Symbols.redeem,
      Symbols.volunteer_activism,
      Symbols.inventory_2
    ],

    // Education & Work
    'school': [Symbols.school, Symbols.menu_book, Symbols.auto_stories],
    'course': [Symbols.library_books, Symbols.class_, Symbols.assignment],
    'work': [
      Symbols.work,
      Symbols.business_center,
      Symbols.laptop_mac,
      Symbols.work_history
    ],
    'office': [Symbols.desk, Symbols.print, Symbols.meeting_room],

    // Home
    'home': [Symbols.home, Symbols.cottage, Symbols.chair, Symbols.bed],
    'repair': [Symbols.construction, Symbols.home_repair_service],
    'clean': [Symbols.local_laundry_service],
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

    // Check for partial matches in glyph names
    _iconGlyphMap.forEach((codePoint, glyphName) {
      final normalizedGlyphName = glyphName.toLowerCase();
      if (normalizedGlyphName.contains(normalizedName)) {
        final icon = allIconsMap[codePoint];
        if (icon != null) {
          suggestions.add(icon);
        }
      }
    });

    return suggestions.toList();
  }

  /// Converts a codePoint string to IconData by looking it up in the dictionary
  /// Returns null if the string is null, empty, cannot be parsed, or the icon doesn't exist
  /// This ensures handshaking - only icons from the predefined set are returned
  static IconData? getIconData(String? codePointString) {
    if (codePointString == null || codePointString.isEmpty) {
      return null;
    }

    final codePoint = int.tryParse(codePointString);
    if (codePoint != null) {
      return allIconsMap[codePoint];
    }

    return null;
  }

  /// Returns a list of all icons with their icon data, codepoint, and glyph code
  /// Each entry contains:
  /// - icon: The IconData object
  /// - codepoint: The numeric codepoint value
  /// - glyphCode: The string identifier (e.g., 'attach_money', 'restaurant')
  static List<Map<String, dynamic>> getAllIconsInfo() {
    return _iconList.map((icon) {
      return {
        'icon': icon,
        'codepoint': icon.codePoint,
        'glyphCode': _iconGlyphMap[icon.codePoint] ?? 'unknown',
      };
    }).toList();
  }
}
