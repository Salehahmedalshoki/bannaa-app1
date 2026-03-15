import 'package:flutter_test/flutter_test.dart';
import 'package:bannaa_app/models/project_model.dart';

void main() {
  group('Project Model Tests', () {
    test('should create project with default values', () {
      final project = Project(
        id: 'test-1',
        name: 'Test Project',
        buildingType: BuildingType.villa,
        floors: 2,
        city: 'Riyadh',
        createdAt: DateTime.now(),
      );

      expect(project.name, 'Test Project');
      expect(project.floors, 2);
      expect(project.city, 'Riyadh');
      expect(project.components, isEmpty);
    });

    test('should calculate total volume', () {
      final project = Project(
        id: 'test-2',
        name: 'Volume Test',
        buildingType: BuildingType.apartment,
        floors: 3,
        city: 'Jeddah',
        createdAt: DateTime.now(),
        components: [
          const BuildingComponent(
            id: 'c1',
            type: ComponentType.column,
            name: 'Column 1',
            length: 0.3,
            width: 0.3,
            height: 3.0,
            count: 4,
          ),
        ],
      );

      // volume = 0.3 * 0.3 * 3.0 * 4 = 1.08
      expect(project.totalVolume, 1.08);
    });

    test('should calculate materials correctly', () {
      final project = Project(
        id: 'test-3',
        name: 'Materials Test',
        buildingType: BuildingType.commercial,
        floors: 1,
        city: 'Dammam',
        createdAt: DateTime.now(),
        components: [
          const BuildingComponent(
            id: 'c2',
            type: ComponentType.slab,
            name: 'Slab',
            length: 10,
            width: 10,
            height: 0.2,
            count: 1,
          ),
        ],
      );

      final materials = project.calculateMaterials();
      expect(materials.isNotEmpty, true);
      expect(materials.first.name, 'أسمنت');
    });
  });

  group('ConcreteGrade Tests', () {
    test('should have correct cement values', () {
      expect(ConcreteGrade.C20.cementKg, 350);
      expect(ConcreteGrade.C30.cementKg, 420);
      expect(ConcreteGrade.C40.cementKg, 480);
    });

    test('should have correct steel values', () {
      expect(ConcreteGrade.C20.steelKg, 100);
      expect(ConcreteGrade.C30.steelKg, 120);
      expect(ConcreteGrade.C40.steelKg, 140);
    });
  });

  group('ReinforcementType Tests', () {
    test('should have correct kg per m3', () {
      expect(ReinforcementType.traditional.kgPerM3, 100);
      expect(ReinforcementType.weldedMesh.kgPerM3, 85);
      expect(ReinforcementType.ringSteel.kgPerM3, 90);
      expect(ReinforcementType.fiber.kgPerM3, 120);
    });
  });

  group('BuildingType Tests', () {
    test('should have labels and emojis', () {
      expect(BuildingType.villa.label, 'فيلا سكنية');
      expect(BuildingType.villa.emoji, '🏠');
      expect(BuildingType.warehouse.label, 'مستودع');
      expect(BuildingType.warehouse.emoji, '🏭');
    });
  });
}
