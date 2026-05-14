import 'package:flutter/material.dart';

class FinancePalette {
  final String id;
  final String name;
  final List<Color> colors;

  const FinancePalette({
    required this.id,
    required this.name,
    required this.colors,
  });

  static const List<FinancePalette> availablePalettes = [
    FinancePalette(
      id: 'default',
      name: 'Modern Dark',
      colors: [
        Color(0xFF818CF8), // Indigo
        Color(0xFF34D399), // Emerald
        Color(0xFFFB923C), // Amber
        Color(0xFFF472B6), // Pink
        Color(0xFF60A5FA), // Sky
        Color(0xFFA78BFA), // Violet
        Color(0xFF2DD4BF), // Teal
        Color(0xFFFB7185), // Rose
      ],
    ),
    FinancePalette(
      id: 'vibrant',
      name: 'Vibrant Neo',
      colors: [
        Color(0xFF6366F1), // Indigo 500
        Color(0xFFEC4899), // Pink 500
        Color(0xFFF59E0B), // Amber 500
        Color(0xFF10B981), // Emerald 500
        Color(0xFF3B82F6), // Blue 500
        Color(0xFF8B5CF6), // Violet 500
        Color(0xFFEF4444), // Red 500
        Color(0xFF06B6D4), // Cyan 500
      ],
    ),
    FinancePalette(
      id: 'pastel',
      name: 'Soft Pastel',
      colors: [
        Color(0xFFA5B4FC), // Indigo 300
        Color(0xFFF9A8D4), // Pink 300
        Color(0xFFFCD34D), // Amber 300
        Color(0xFF6EE7B7), // Emerald 300
        Color(0xFF93C5FD), // Blue 300
        Color(0xFFC4B5FD), // Violet 300
        Color(0xFFFDA4AF), // Rose 300
        Color(0xFF67E8F9), // Cyan 300
      ],
    ),
    FinancePalette(
      id: 'monochrome',
      name: 'Zinc Shades',
      colors: [
        Color(0xFFFAFAFA), // Zinc 50
        Color(0xFFE4E4E7), // Zinc 200
        Color(0xFFD4D4D8), // Zinc 300
        Color(0xFFA1A1AA), // Zinc 400
        Color(0xFF71717A), // Zinc 500
        Color(0xFF52525B), // Zinc 600
        Color(0xFF3F3F46), // Zinc 700
        Color(0xFF27272A), // Zinc 800
      ],
    ),
    FinancePalette(
      id: 'ocean',
      name: 'Deep Ocean',
      colors: [
        Color(0xFF0EA5E9), // Sky 500
        Color(0xFF0284C7), // Sky 600
        Color(0xFF0369A1), // Sky 700
        Color(0xFF075985), // Sky 800
        Color(0xFF0C4A6E), // Sky 900
        Color(0xFF2DD4BF), // Teal 400
        Color(0xFF14B8A6), // Teal 500
        Color(0xFF0F766E), // Teal 700
      ],
    ),
    FinancePalette(
      id: 'sunset',
      name: 'Sunset Glow',
      colors: [
        Color(0xFFFF4D4D), // Bright Red
        Color(0xFFFF7E5F), // Coral
        Color(0xFFFEB47B), // Peach
        Color(0xFFFFD93D), // Yellow
        Color(0xFF6A11CB), // Purple
        Color(0xFF2575FC), // Blue
        Color(0xFFFF0080), // Hot Pink
        Color(0xFF7928CA), // Deep Purple
      ],
    ),
    FinancePalette(
      id: 'forest',
      name: 'Forest Moss',
      colors: [
        Color(0xFF1B4332), // Dark Green
        Color(0xFF2D6A4F), // Forest
        Color(0xFF40916C), // Moss
        Color(0xFF52B788), // Sage
        Color(0xFF74C69D), // Light Sage
        Color(0xFF95D5B2), // Mint
        Color(0xFFB7E4C7), // Pale Mint
        Color(0xFFD8F3DC), // Off White Green
      ],
    ),
    FinancePalette(
      id: 'cyberpunk',
      name: 'Cyber Neon',
      colors: [
        Color(0xFF00FF9F), // Neon Green
        Color(0xFF00B8FF), // Neon Blue
        Color(0xFF001AFF), // Deep Blue
        Color(0xFFBD00FF), // Neon Purple
        Color(0xFFD600FF), // Neon Magenta
        Color(0xFFFF00E0), // Hot Pink
        Color(0xFFFF0055), // Bright Red
        Color(0xFFFF9E00), // Neon Orange
      ],
    ),
    FinancePalette(
      id: 'earth',
      name: 'Earth Tones',
      colors: [
        Color(0xFF432818), // Dark Brown
        Color(0xFF99582A), // Brown
        Color(0xFFBB9457), // Ochre
        Color(0xFF606C38), // Olive
        Color(0xFF283618), // Dark Olive
        Color(0xFFDDA15E), // Tan
        Color(0xFFFEFAE0), // Cream
        Color(0xFFA68A64), // Taupe
      ],
    ),
    FinancePalette(
      id: 'midnight',
      name: 'Midnight Bloom',
      colors: [
        Color(0xFF1E1E2E), // Deep Navy
        Color(0xFF313244), // Slate
        Color(0xFF45475A), // Gray
        Color(0xFF585B70), // Light Gray
        Color(0xFFF5E0DC), // Rosewater
        Color(0xFFF2CDCD), // Flamingo
        Color(0xFFF5C2E7), // Pink
        Color(0xFFCBA6F7), // Mauve
      ],
    ),
  ];

  static FinancePalette getPalette(String id) {
    return availablePalettes.firstWhere(
      (p) => p.id == id,
      orElse: () => availablePalettes.first,
    );
  }
}
