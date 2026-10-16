import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const TwinGridApp());
}

class TwinGridApp extends StatelessWidget {
  const TwinGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TwinGrid-AI Engine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF090D16),
        cardColor: const Color(0xFF131B2E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFF7C4DFF),
          surface: Color(0xFF131B2E),
          error: Color(0xFFFF5252),
        ),
      ),
      home: const MainDashboardScreen(),
    );
  }
}

enum TwinModule { ecoTwin, bioTwin, crossTwin, studyLab }

class SystemState {
  double riverSalinityPpt = 14.2;
  double floodErosionRiskPercent = 78.5;
  int userSystolicBp = 142;
  int userDiastolicBp = 92;
  double bloodGlucoseMgDl = 138.0;
  bool activeAlert = true;

  void updateSimulationStep() {
    final random = math.Random();
    riverSalinityPpt = (riverSalinityPpt + (random.nextDouble() * 0.4 - 0.2)).clamp(5.0, 25.0);
    floodErosionRiskPercent = (floodErosionRiskPercent + (random.nextDouble() * 1.2 - 0.6)).clamp(10.0, 99.0);
    
    // CrossTwin Correlation Logic: High Environmental Salinity directly inflates User BP Simulation
    if (riverSalinityPpt > 12.0) {
      userSystolicBp = (135 + (riverSalinityPpt * 0.7).round()).clamp(110, 180);
      userDiastolicBp = (85 + (riverSalinityPpt * 0.4).round()).clamp(70, 110);
    } else {
      userSystolicBp = 120;
      userDiastolicBp = 80;
    }
  }
}

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  TwinModule _currentModule = TwinModule.crossTwin;
  final SystemState _systemState = SystemState();
  Timer? _simulationTimer;

  @override
  void initState() {
    super.initState();
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _systemState.updateSimulationStep();
      });
    });
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 4,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.hub, color: Color(0xFF00E5FF), size: 24),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAlignment.start,
              children: [
                Text('TwinGrid-AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                Text('SYSTEM-OF-SYSTEMS ENGINE', style: TextStyle(fontSize: 10, color: Color(0xFF00E5FF), letterSpacing: 1.2)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Color(0xFFFF5252)),
            onPressed: () => _showCrossTwinAlertModal(context),
          ),
        ],
      ),
      body: Row(
        children: [
          _buildNavigationRail(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildSelectedModuleView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRail() {
    return NavigationRail(
      selectedIndex: _currentModule.index,
      backgroundColor: const Color(0xFF0B1120),
      onDestinationSelected: (int index) {
        setState(() {
          _currentModule = TwinModule.values[index];
        });
      },
      labelType: NavigationRailLabelType.all,
      selectedIconTheme: const IconThemeData(color: Color(0xFF00E5FF), size: 28),
      unselectedIconTheme: const IconThemeData(color: Colors.white54, size: 22),
      selectedLabelStyle: const TextStyle(color: Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(color: Colors.white54, fontSize: 11),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.public),
          label: Text('EcoTwin'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.favorite),
          label: Text('BioTwin'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.alt_route),
          label: Text('CrossTwin'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.menu_book),
          label: Text('Study Lab'),
        ),
      ],
    );
  }

  Widget _buildSelectedModuleView() {
    switch (_currentModule) {
      case TwinModule.ecoTwin:
        return EcoTwinView(state: _systemState);
      case TwinModule.bioTwin:
        return BioTwinView(state: _systemState);
      case TwinModule.crossTwin:
        return CrossTwinView(state: _systemState);
      case TwinModule.studyLab:
        return const StudyLabView();
    }
  }

  void _showCrossTwinAlertModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Color(0xFFFF5252)),
            SizedBox(width: 10),
            Text('CrossTwin Risk Warning', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'Coastal River Salinity at Meghna Delta has crossed ${_systemState.riverSalinityPpt.toStringAsFixed(1)} ppt.\n\n'
          'AI Simulation predicts a 34% increase in local hypertension cases over the next 48 hours. Biological Twins have been updated with reduced sodium intake limits.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ACKNOWLEDGE', style: TextStyle(color: Color(0xFF00E5FF))),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 1. ECOTWIN VIEW (Environmental Delta Twin)
// ==========================================
class EcoTwinView extends StatelessWidget {
  final SystemState state;
  const EcoTwinView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeaderCard('EcoTwin: Coastal & Delta Spatial Grid', 'Live Synthetic Aperture Radar (SAR) & River Hydrodynamics'),
        const SizedBox(height: 16),
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CustomPaint(
              painter: RiverDeltaMeshPainter(erosionRisk: state.floodErosionRiskPercent),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black80,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF00E5FF)),
                      ),
                      child: const Text('LIVE PINN SIMULATION: MEGHNA DELTA', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildMetricCard('Salinity Level', '${state.riverSalinityPpt.toStringAsFixed(1)} ppt', Icons.water_drop, Colors.cyan)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('Erosion Risk', '${state.floodErosionRiskPercent.toStringAsFixed(1)}%', Icons.landscape, const Color(0xFFFF5252))),
          ],
        ),
      ],
    );
  }
}

// Custom Mesh Painter simulating 3D Spatial Delta Hydrodynamics
class RiverDeltaMeshPainter extends CustomPainter {
  final double erosionRisk;
  RiverDeltaMeshPainter({required this.erosionRisk});

  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final paintRiver = Paint()
      ..color = Color.lerp(const Color(0xFF00E5FF), const Color(0xFFFF5252), erosionRisk / 100)!
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    // Draw Spatial Perspective Grid
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i * 1.5 - size.width * 0.25, size.height), paintGrid);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paintGrid);
    }

    // Draw Dynamic River Vector Curve
    final path = Path();
    path.moveTo(size.width * 0.1, 0);
    path.cubicTo(size.width * 0.4, size.height * 0.3, size.width * 0.2, size.height * 0.7, size.width * 0.8, size.height);
    canvas.drawPath(path, paintRiver);
  }

  @override
  bool shouldRepaint(covariant RiverDeltaMeshPainter oldDelegate) => oldDelegate.erosionRisk != erosionRisk;
}

// ==========================================
// 2. BIOTWIN VIEW (Human Medical Digital Twin)
// ==========================================
class BioTwinView extends StatelessWidget {
  final SystemState state;
  const BioTwinView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeaderCard('BioTwin: Human Physiological Digital Twin', 'Real-Time ECG, Blood Dynamics & Metabolic Predictive AI'),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.3)),
          ),
          child: CustomPaint(
            painter: OrganMeshPainter(bp: state.userSystolicBp),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite, size: 64, color: Color(0xFF7C4DFF)),
                  const SizedBox(height: 8),
                  Text('Cardiovascular Model Active', style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold)),
                  Text('Predicted Stress Index: ${((state.userSystolicBp - 100) / 80 * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Color(0xFF7C4DFF), fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildMetricCard('Blood Pressure', '${state.userSystolicBp}/${state.userDiastolicBp} mmHg', Icons.speed, state.userSystolicBp > 130 ? const Color(0xFFFF5252) : const Color(0xFF00E5FF))),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('Blood Glucose', '${state.bloodGlucoseMgDl.toStringAsFixed(0)} mg/dL', Icons.bloodtype, const Color(0xFF7C4DFF))),
          ],
        ),
      ],
    );
  }
}

class OrganMeshPainter extends CustomPainter {
  final int bp;
  OrganMeshPainter({required this.bp});

  @override
  void paint(Canvas canvas, Size size) {
    final paintPulse = Paint()
      ..color = const Color(0xFF7C4DFF).withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final double radius = (bp / 2.0).clamp(40.0, 90.0);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paintPulse);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius * 1.3, paintPulse);
  }

  @override
  bool shouldRepaint(covariant OrganMeshPainter oldDelegate) => oldDelegate.bp != bp;
}

// ==========================================
// 3. CROSSTWIN VIEW (Unified Hybrid Engine)
// ==========================================
class CrossTwinView extends StatelessWidget {
  final SystemState state;
  const CrossTwinView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeaderCard('CrossTwin Engine: Environmental & Health Fusion', 'Correlating Climate Physics directly with Human Metabolic Stress'),
        const SizedBox(height: 16),
        Card(
          color: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.hub, color: Color(0xFF00E5FF)),
                    SizedBox(width: 8),
                    Text('Active Correlation Map', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const Divider(color: Colors.white12, height: 24),
                _buildCorrelationRow('River Salinity (EcoTwin)', '${state.riverSalinityPpt.toStringAsFixed(1)} ppt', 'Systolic Blood Pressure (BioTwin)', '${state.userSystolicBp} mmHg', true),
                const SizedBox(height: 12),
                _buildCorrelationRow('Monsoon Flood Risk (EcoTwin)', '${state.floodErosionRiskPercent.toStringAsFixed(1)}%', 'Waterborne Epidemic Risk (BioTwin)', 'Elevated (High)', false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCorrelationRow(String envMetric, String envVal, String bioMetric, String bioVal, bool Danger) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Danger ? const Color(0xFFFF5252).withOpacity(0.5) : Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAlignment.start,
              children: [
                Text(envMetric, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                Text(envVal, style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
          const Icon(Icons.sync_alt, color: Color(0xFF7C4DFF)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAlignment.end,
              children: [
                Text(bioMetric, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                Text(bioVal, style: TextStyle(color: Danger ? const Color(0xFFFF5252) : const Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. STUDY LAB VIEW (Built-in Research Platform)
// ==========================================
class StudyLabView extends StatelessWidget {
  const StudyLabView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeaderCard('TwinGrid Study & Research Lab', 'Academic Papers, System Documentation & Delta Plan 2100 Guidelines'),
        const SizedBox(height: 16),
        _buildStudyCard('Physics-Informed Neural Networks (PINNs) in Hydrology', 'Learn how Navier-Stokes equations are embedded into deep learning loss functions for non-linear river modeling.'),
        _buildStudyCard('Human Digital Twins (HDT) & Metabolic Health', 'Comprehensive study on continuous glucose monitoring and cardiac predictive modeling.'),
        _buildStudyCard('Bangladesh Delta Plan 2100 (BDP 2100) Alignment', 'Technical frameworks for integrating GIS spatial radar grids with national early warning infrastructure.'),
      ],
    );
  }

  Widget _buildStudyCard(String title, String summary) {
    return Card(
      color: const Color(0xFF131B2E),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.article, color: Color(0xFF00E5FF)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(summary, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 14),
        onTap: () {},
      ),
    );
  }
}

// Shared UI Components
Widget _buildHeaderCard(String title, String subtitle) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white10),
    ),
    child: Column(
      crossAxisAlignment: CrossAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12)),
      ],
    ),
  );
}

Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF131B2E),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            Icon(icon, color: color, size: 20),
          ],
        ),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}