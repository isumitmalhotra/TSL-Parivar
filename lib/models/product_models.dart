/// TSL Product Catalog Models
///
/// Contains comprehensive product data for all TSL products
/// including specifications, features, and images.

import 'package:flutter/material.dart';

/// Product category enum
enum ProductCategory {
  tmtBars,
  wires,
  roundPipe,
  squarePipe,
  colourCoatedSheets,
  angles,
  channels,
  girders,
}

extension ProductCategoryExtension on ProductCategory {
  String get displayName {
    switch (this) {
      case ProductCategory.tmtBars:
        return 'TSL 550 SD';
      case ProductCategory.wires:
        return 'TSL Wires';
      case ProductCategory.roundPipe:
        return 'Round Pipe';
      case ProductCategory.squarePipe:
        return 'Square Pipe';
      case ProductCategory.colourCoatedSheets:
        return 'Duro Colour';
      case ProductCategory.angles:
        return 'TSL Angles';
      case ProductCategory.channels:
        return 'TSL Channels';
      case ProductCategory.girders:
        return 'TSL Girders';
    }
  }

  IconData get icon {
    switch (this) {
      case ProductCategory.tmtBars:
        return Icons.view_column;
      case ProductCategory.wires:
        return Icons.cable;
      case ProductCategory.roundPipe:
        return Icons.circle_outlined;
      case ProductCategory.squarePipe:
        return Icons.crop_square;
      case ProductCategory.colourCoatedSheets:
        return Icons.grid_on;
      case ProductCategory.angles:
        return Icons.change_history;
      case ProductCategory.channels:
        return Icons.view_stream;
      case ProductCategory.girders:
        return Icons.straighten;
    }
  }

  Color get color {
    switch (this) {
      case ProductCategory.tmtBars:
        return const Color(0xFF2E7D32);
      case ProductCategory.wires:
        return const Color(0xFF1565C0);
      case ProductCategory.roundPipe:
        return const Color(0xFFE65100);
      case ProductCategory.squarePipe:
        return const Color(0xFF6A1B9A);
      case ProductCategory.colourCoatedSheets:
        return const Color(0xFFC62828);
      case ProductCategory.angles:
        return const Color(0xFF00838F);
      case ProductCategory.channels:
        return const Color(0xFF4E342E);
      case ProductCategory.girders:
        return const Color(0xFF37474F);
    }
  }
}

/// Product specification item
class ProductSpec {
  final String label;
  final String value;

  const ProductSpec({required this.label, required this.value});
}

/// Product advantage/feature
class ProductAdvantage {
  final String title;
  final String description;
  final IconData icon;

  const ProductAdvantage({
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// Complete TSL Product model
class TslProduct {
  final String id;
  final String name;
  final String tagline;
  final String description;
  final ProductCategory category;
  final String imagePath;
  final List<ProductAdvantage> advantages;
  final List<ProductSpec> specifications;
  final List<String> applications;
  final List<String> availableUnits;
  final List<String> grades;

  const TslProduct({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.category,
    required this.imagePath,
    required this.advantages,
    required this.specifications,
    required this.applications,
    required this.availableUnits,
    required this.grades,
  });
}

/// TSL Product Catalog - All real product data
class TslProductCatalog {
  TslProductCatalog._();

  static const List<TslProduct> allProducts = [
    // 1. TSL 550 SD TMT Bars
    TslProduct(
      id: 'prod_tmt_bars',
      name: 'TSL 550 SD',
      tagline: 'Strength That Forms the Spine',
      description:
          'TSL Saria is more than just reinforcement steel — it\'s the trusted foundation of modern construction. Crafted from premium iron ore and manufactured using state-of-the-art refining and rolling technology, TSL Saria delivers unmatched strength, ductility, and long-term durability.\n\nWith a commitment to engineering excellence and structural safety, every TSL Saria is designed to meet the rigorous demands of high-rise buildings, earthquake-prone zones, bridges, and infrastructure that lasts for generations.',
      category: ProductCategory.tmtBars,
      imagePath: 'assets/images/products/tmt_bars.jpg',
      advantages: [
        ProductAdvantage(
          title: 'High Strength with Flexibility',
          description:
              'Manufactured in Fe-550SD grade, offering superior tensile strength with high ductility — perfect for RCC applications in both residential and industrial structures.',
          icon: Icons.fitness_center,
        ),
        ProductAdvantage(
          title: 'Virgin-Grade Iron Ore',
          description:
              'Produced only from high-quality iron ore (no scrap), ensuring refined chemical properties, low sulphur-phosphorus content, and consistent quality in every bar.',
          icon: Icons.diamond,
        ),
        ProductAdvantage(
          title: 'Advanced Technology',
          description:
              'Made using Ladle Refining Furnace (LRF) and fully automated rolling mills, delivering perfect microstructure control, grain uniformity, and strength.',
          icon: Icons.precision_manufacturing,
        ),
        ProductAdvantage(
          title: 'Superior Bonding with Concrete',
          description:
              'Engineered with uniform ribs and precise ridges for enhanced grip and bonding with cement, ensuring structural stability in all conditions.',
          icon: Icons.handshake,
        ),
        ProductAdvantage(
          title: 'Earthquake & Fire Resistant',
          description:
              'Made to withstand seismic stress and high temperature zones, offering reliability even in extreme conditions.',
          icon: Icons.shield,
        ),
        ProductAdvantage(
          title: 'Weldability & Workability',
          description:
              'Low carbon composition makes TSL Saria easy to weld, bend, and cut — saving time and labour on site.',
          icon: Icons.construction,
        ),
      ],
      specifications: [
        ProductSpec(label: 'Diameter Range', value: '8 mm to 40 mm'),
        ProductSpec(
            label: 'Length Options',
            value: 'Standard 12 metres (customizable on request)'),
        ProductSpec(
            label: 'Forms Available',
            value: 'Straight length (Coil form — Coming Soon)'),
        ProductSpec(
            label: 'Grades Offered',
            value: 'Fe-550SD (Standard), Higher Grades on project request'),
      ],
      applications: [
        'High-rise buildings',
        'Earthquake-prone zones',
        'Bridges',
        'Infrastructure projects',
        'RCC applications',
      ],
      availableUnits: ['kg', 'tonnes', 'quintal'],
      grades: ['Fe-500', 'Fe-550 SD', 'Fe-600'],
    ),

    // 2. TSL Wires
    TslProduct(
      id: 'prod_wires',
      name: 'TSL Wires',
      tagline: 'The Unseen Strength',
      description:
          'Every masterpiece of construction rests not only on steel and cement, but on the connections that hold it all together. TSL Binding Wire is the invisible force that ties it all — a product designed for maximum strength, flexibility, and grip to ensure structural reinforcement bars are held securely in place throughout the construction process.\n\nMade from high-grade mild steel, processed through precision galvanizing and annealing, our binding wire ensures uniformity, corrosion resistance, and high elongation — perfect for use in residential, commercial, and infrastructure projects.',
      category: ProductCategory.wires,
      imagePath: 'assets/images/products/tmt_bars.jpg',
      advantages: [
        ProductAdvantage(
          title: 'High Ductility & Flexibility',
          description:
              'Bends easily without snapping — allows perfect binding even at complicated rebar joints, saving time and labour.',
          icon: Icons.swap_calls,
        ),
        ProductAdvantage(
          title: 'Corrosion Resistant Finish',
          description:
              'Electro-galvanised/annealed wire that prevents rusting during construction or prolonged site exposure.',
          icon: Icons.water_drop,
        ),
        ProductAdvantage(
          title: 'Uniform Thickness, Consistent Grip',
          description:
              'Precision-drawn to deliver consistent performance, better twist hold, and equal stress distribution.',
          icon: Icons.straighten,
        ),
        ProductAdvantage(
          title: 'Lightweight, Heavy Duty',
          description:
              'Despite being light in weight and easy to handle, it offers excellent tensile properties, making it ideal for high-load structures.',
          icon: Icons.fitness_center,
        ),
        ProductAdvantage(
          title: 'Smooth Handling',
          description:
              'Soft texture, kink-free, and coil-form availability ensures faster tying with less fatigue for site workers.',
          icon: Icons.touch_app,
        ),
      ],
      specifications: [
        ProductSpec(
            label: 'Material Used', value: 'MS (Mild Steel), Annealed / Galvanised'),
        ProductSpec(label: 'Wire Diameter', value: '0.89 mm to 1.60 mm'),
        ProductSpec(
            label: 'Tensile Strength',
            value: '300 – 450 MPa (customizable on order)'),
        ProductSpec(label: 'Coil Weight', value: '20 – 50 kg (standard)'),
      ],
      applications: [
        'RCC works',
        'Rebar binding',
        'Scaffolding joints',
        'Construction framework',
      ],
      availableUnits: ['kg', 'bundles'],
      grades: ['18 Gauge', '20 Gauge', '22 Gauge'],
    ),

    // 3. TSL Round Pipe
    TslProduct(
      id: 'prod_round_pipe',
      name: 'TSL Round Pipe',
      tagline: 'Flow with Power',
      description:
          'TSL MS Round Pipes are the perfect fusion of strength, precision, and flexibility — offering unmatched versatility for fluid transport, mechanical structures, and architectural applications. Built from premium mild steel and formed with expert control, these pipes deliver consistent circular geometry and high tensile capacity, making them ideal for dynamic pressure and structural environments.\n\nWhether it\'s for pipelines, industrial machines, or scaffolding, TSL MS Round Pipes bring the power of flow and the confidence of strength to every project.',
      category: ProductCategory.roundPipe,
      imagePath: 'assets/images/products/ms_pipe_round.jpg',
      advantages: [
        ProductAdvantage(
          title: 'Precision Circular Form',
          description:
              'Flawlessly round, seamless edge profiles ensure smooth flow in liquid/gas applications and geometric balance in structural installations.',
          icon: Icons.circle_outlined,
        ),
        ProductAdvantage(
          title: 'Superior Strength & Tensile Capacity',
          description:
              'Engineered to endure pressure and load conditions without deformation, cracking, or fatigue.',
          icon: Icons.fitness_center,
        ),
        ProductAdvantage(
          title: 'Easy Formability & Weldability',
          description:
              'Manufactured to allow clean cuts, smooth bending, and flawless welding — even under time-sensitive project conditions.',
          icon: Icons.construction,
        ),
        ProductAdvantage(
          title: 'Multiple Sizes & Wall Thickness',
          description:
              'Customizable to suit both high- and low-pressure applications, ensuring compatibility across industry segments.',
          icon: Icons.tune,
        ),
        ProductAdvantage(
          title: 'Rust-Resistant & Durable',
          description:
              'Optional coatings and tight mill tolerance reduce corrosion risk, offering longevity even in open or harsh environments.',
          icon: Icons.shield,
        ),
      ],
      specifications: [
        ProductSpec(label: 'Material', value: 'Mild Steel (MS)'),
        ProductSpec(label: 'Outer Diameter', value: '15 mm – 200 mm'),
        ProductSpec(label: 'Thickness', value: '1.0 mm – 6.0 mm'),
        ProductSpec(
            label: 'Length', value: 'Standard 6 meters / customizable'),
        ProductSpec(label: 'Grades', value: 'IS 1239 / IS 1161'),
      ],
      applications: [
        'Plumbing',
        'Exhaust systems',
        'Industrial scaffolding',
        'Fencing',
        'Structural columns',
      ],
      availableUnits: ['pcs', 'metres'],
      grades: ['15mm', '20mm', '25mm', '32mm', '40mm'],
    ),

    // 4. TSL Square Pipe
    TslProduct(
      id: 'prod_square_pipe',
      name: 'TSL Square Pipe',
      tagline: 'Geometry with Strength',
      description:
          'Where design meets durability, TSL MS Square Pipes provide a bold, modern solution for architectural and structural needs. Built from high-quality mild steel and manufactured in state-of-the-art mills, these pipes offer unmatched strength, dimensional precision, and geometric stability.\n\nIdeal for construction, industrial frameworks, and interior design elements, TSL Square Pipes are not just functional — they deliver on aesthetic value, structural support, and long-term reliability in even the most demanding applications.',
      category: ProductCategory.squarePipe,
      imagePath: 'assets/images/products/ms_pipe_square.jpg',
      advantages: [
        ProductAdvantage(
          title: 'Geometric Accuracy',
          description:
              'Precisely engineered with sharp edges and uniform square profiles that support symmetry and even load distribution.',
          icon: Icons.crop_square,
        ),
        ProductAdvantage(
          title: 'Superior Surface Finish',
          description:
              'Clean, smooth finish that\'s ideal for visible structures and projects where appearance matters as much as performance.',
          icon: Icons.auto_awesome,
        ),
        ProductAdvantage(
          title: 'High Load-Bearing Capacity',
          description:
              'Built to carry weight with minimal deflection or stress deformation — perfect for fabrication and structural bracing.',
          icon: Icons.fitness_center,
        ),
        ProductAdvantage(
          title: 'Customizability & Weldability',
          description:
              'Available in multiple wall thicknesses, lengths, and grades — all easily weldable for a variety of applications.',
          icon: Icons.construction,
        ),
        ProductAdvantage(
          title: 'Corrosion-Ready Coating',
          description:
              'Available with protective coatings upon request for outdoor or moisture-exposed projects.',
          icon: Icons.shield,
        ),
      ],
      specifications: [
        ProductSpec(label: 'Material', value: 'Mild Steel (MS)'),
        ProductSpec(label: 'Outer Dimension', value: '15 mm – 120 mm'),
        ProductSpec(label: 'Thickness', value: '1.0 mm – 5.0 mm'),
        ProductSpec(
            label: 'Length',
            value: 'Standard 6 meters (custom lengths available)'),
        ProductSpec(label: 'Grades', value: 'IS 4923 / IS 1161 compliant'),
      ],
      applications: [
        'Structural frames',
        'Gates',
        'Railings',
        'Modular furniture',
        'Agriculture equipment',
      ],
      availableUnits: ['pcs', 'metres'],
      grades: ['15mm', '20mm', '25mm', '40mm'],
    ),

    // 5. TSL Duro Colour
    TslProduct(
      id: 'prod_duro_colour',
      name: 'TSL Duro Colour',
      tagline: 'Strength with Style',
      description:
          'Add vibrant protection to your structures with TSL Colour Coated Sheets — where aesthetics meet performance. Manufactured with precision rolling and coated with UV- and corrosion-resistant paint layers, these sheets are made to last and impress.\n\nPerfect for roofing, cladding, and facades, TSL Colour Coated Sheets offer long-term weather resistance, colour stability, and excellent structural strength. A solution tailored for modern design and long-lasting resilience.',
      category: ProductCategory.colourCoatedSheets,
      imagePath: 'assets/images/products/colour_coated_sheets.jpg',
      advantages: [
        ProductAdvantage(
          title: 'High Strength Base Steel',
          description:
              'Cold-rolled, high-tensile steel substrate ensures rigidity and load-bearing capacity.',
          icon: Icons.fitness_center,
        ),
        ProductAdvantage(
          title: 'Superior Coating & Finish',
          description:
              'Multi-layered paint coating system (primer + finish) for excellent gloss, texture, and weather endurance.',
          icon: Icons.palette,
        ),
        ProductAdvantage(
          title: 'UV & Corrosion Resistant',
          description:
              'Designed to handle harsh Indian climates, coastal winds, and direct sunlight without fading or rusting.',
          icon: Icons.wb_sunny,
        ),
        ProductAdvantage(
          title: 'Thermal & Sound Insulation',
          description:
              'Enhances roofing performance by reflecting heat and reducing rain noise.',
          icon: Icons.thermostat,
        ),
        ProductAdvantage(
          title: 'Wide Range of Colours & Profiles',
          description:
              'Available in trapezoidal, tile, and sinusoidal profiles — tailored to your design and project needs.',
          icon: Icons.color_lens,
        ),
      ],
      specifications: [
        ProductSpec(
            label: 'Base Metal', value: 'Cold Rolled Steel (CR) / Galvanised'),
        ProductSpec(label: 'Thickness', value: '0.30 mm – 1.00 mm'),
        ProductSpec(label: 'Width', value: '600 mm – 1250 mm'),
        ProductSpec(label: 'Coating', value: 'RMP / SMP / PVDF'),
      ],
      applications: [
        'Roofing',
        'Wall cladding',
        'Sheds',
        'Warehouses',
        'Facades',
      ],
      availableUnits: ['sheets', 'sq.ft'],
      grades: ['0.35mm', '0.40mm', '0.45mm', '0.50mm'],
    ),

    // 6. TSL Angles
    TslProduct(
      id: 'prod_angles',
      name: 'TSL Angles',
      tagline: 'Right Angles, Right Results',
      description:
          'TSL Steel Angles are the cornerstone of structural stability, offering superior strength, excellent load-carrying capacity, and versatile use across industries. Crafted from high-quality mild steel and manufactured to exacting standards, these angles are the trusted choice for engineers, architects, and industrial fabricators.\n\nUsed in trusses, towers, bridges, frames, and more — TSL Angles deliver unmatched performance in tension and compression, providing essential support where it matters most.',
      category: ProductCategory.angles,
      imagePath: 'assets/images/products/angles.jpg',
      advantages: [
        ProductAdvantage(
          title: 'Superior Structural Support',
          description:
              'Ideal for cross-bracing, tension loads, and corner framing — adding rigidity and reducing deformation.',
          icon: Icons.architecture,
        ),
        ProductAdvantage(
          title: 'Consistent Cross-Sectional Accuracy',
          description:
              'Designed with precise dimensions and clean edges for reliable fit and consistent fabrication.',
          icon: Icons.straighten,
        ),
        ProductAdvantage(
          title: 'High Weldability & Formability',
          description:
              'Easy to cut, drill, and weld without compromising structural integrity — saving fabrication time.',
          icon: Icons.construction,
        ),
        ProductAdvantage(
          title: 'Corrosion Resistance',
          description:
              'Galvanised variants available for weather-exposed or marine applications.',
          icon: Icons.shield,
        ),
        ProductAdvantage(
          title: 'Custom Lengths & Profiles',
          description:
              'Available in equal and unequal leg sizes to suit varying project requirements.',
          icon: Icons.tune,
        ),
      ],
      specifications: [
        ProductSpec(label: 'Material', value: 'Mild Steel (MS)'),
        ProductSpec(
            label: 'Leg Sizes', value: '25 x 25 mm up to 200 x 200 mm'),
        ProductSpec(label: 'Thickness', value: '3 mm – 10 mm'),
        ProductSpec(label: 'Length', value: '6 – 12 meters'),
        ProductSpec(label: 'Grades', value: 'IS 2062 / IS 808 compliant'),
      ],
      applications: [
        'Construction frames',
        'Transmission towers',
        'Sheds',
        'Bridges',
        'Railways',
        'Fabrication works',
      ],
      availableUnits: ['kg', 'pcs'],
      grades: ['25x25', '50x50', '75x75', '100x100'],
    ),

    // 7. TSL Channels
    TslProduct(
      id: 'prod_channels',
      name: 'TSL Channels',
      tagline: 'Shaping the Frame of Strength',
      description:
          'TSL Steel Channels form the backbone of modern structures. Whether used in load-bearing beams, framing, machinery, or support structures, our mild steel channels combine high strength with dimensional accuracy and weldability. Designed to endure pressure, impact, and environmental stress, they are trusted by fabricators, engineers, and infrastructure planners alike.',
      category: ProductCategory.channels,
      imagePath: 'assets/images/products/channels.jpg',
      advantages: [
        ProductAdvantage(
          title: 'High Load-Bearing Capacity',
          description:
              'Ideal for structural bracing and framework in both vertical and horizontal orientations.',
          icon: Icons.fitness_center,
        ),
        ProductAdvantage(
          title: 'Excellent Dimensional Tolerance',
          description:
              'Manufactured with precision control for consistent flange width and thickness.',
          icon: Icons.straighten,
        ),
        ProductAdvantage(
          title: 'Superior Weldability & Machinability',
          description:
              'Easy to cut, join, and shape — even in intricate applications.',
          icon: Icons.construction,
        ),
        ProductAdvantage(
          title: 'Corrosion Protection',
          description:
              'Galvanised and coated variants available for outdoor and marine use.',
          icon: Icons.shield,
        ),
        ProductAdvantage(
          title: 'Multipurpose Use',
          description:
              'From bridges and buildings to truck bodies and towers — versatile in use.',
          icon: Icons.category,
        ),
      ],
      specifications: [
        ProductSpec(label: 'Material', value: 'Mild Steel'),
        ProductSpec(
            label: 'Dimensions', value: '75 x 40 mm up to 400 x 100 mm'),
        ProductSpec(label: 'Thickness', value: '4.8 mm – 10 mm'),
        ProductSpec(label: 'Length', value: '6 – 12 meters'),
        ProductSpec(label: 'Grades', value: 'IS 2062, IS 808 compliant'),
      ],
      applications: [
        'Structural bracing',
        'Columns',
        'Support beams',
        'Chassis fabrication',
      ],
      availableUnits: ['kg', 'metres'],
      grades: ['75mm', '100mm', '125mm', '150mm'],
    ),

    // 8. TSL Girders
    TslProduct(
      id: 'prod_girders',
      name: 'TSL Girders',
      tagline: 'The Giants of Load-Bearing',
      description:
          'TSL Girders bring simplicity, strength, and versatility together in one essential product. Manufactured with precision and consistency from high-quality mild steel, they\'re widely used across engineering, construction, and fabrication applications — wherever reliable reinforcement or foundation support is needed.\n\nWith excellent machinability and formability, TSL Girders are ideal for brackets, base plates, frames, grills, gates, and other core structural elements.',
      category: ProductCategory.girders,
      imagePath: 'assets/images/products/girders.jpg',
      advantages: [
        ProductAdvantage(
          title: 'Multi-Purpose Use',
          description:
              'Can be cut, drilled, welded, or bolted with ease — making them the preferred choice for custom structures.',
          icon: Icons.build,
        ),
        ProductAdvantage(
          title: 'High Load Bearing Strength',
          description:
              'With uniform thickness and width, TSL Girders deliver reliable structural performance under varied loads.',
          icon: Icons.fitness_center,
        ),
        ProductAdvantage(
          title: 'Smooth Surface & Straight Edges',
          description:
              'Ensures ease of fabrication, clean finish, and compatibility with automated manufacturing systems.',
          icon: Icons.auto_awesome,
        ),
        ProductAdvantage(
          title: 'Easy to Handle & Store',
          description:
              'Rectangular shape allows for efficient stacking, cutting, and processing with minimal waste.',
          icon: Icons.inventory_2,
        ),
        ProductAdvantage(
          title: 'Available in Multiple Sizes',
          description:
              'From light-duty to heavy-duty sizes, suited for both small builds and industrial-scale works.',
          icon: Icons.tune,
        ),
      ],
      specifications: [
        ProductSpec(label: 'Material', value: 'Mild Steel (MS)'),
        ProductSpec(label: 'Width Range', value: '20 mm – 300 mm'),
        ProductSpec(label: 'Thickness', value: '3 mm – 25 mm'),
        ProductSpec(
            label: 'Length', value: '6 meters / custom length available'),
        ProductSpec(label: 'Grades', value: 'IS 2062 E250 / E350'),
      ],
      applications: [
        'Structural base plates',
        'Supports',
        'Gate frames',
        'Industrial racks',
        'Fabrication works',
      ],
      availableUnits: ['pcs', 'metres'],
      grades: ['Standard', 'Heavy Duty'],
    ),
  ];

  /// Get product by ID
  static TslProduct? getById(String id) {
    try {
      return allProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get products by category
  static List<TslProduct> getByCategory(ProductCategory category) {
    return allProducts.where((p) => p.category == category).toList();
  }

  /// Get all product names for material selection dropdowns
  static List<String> get productNames =>
      allProducts.map((p) => p.name).toList();
}

