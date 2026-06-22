# Part 4: Persistence and data with SwiftData

The SwiftData-first iOS 26 data stack with Swift-6-clean background work, migrations, and an honest Core
Data coexistence boundary.

## Planned recipes

- **Modeling with SwiftData**: a `@Model` graph, class inheritance and is-type predicates,
  `#Index` / `#Unique` / `#Expression`, an in-memory `ModelContainer` for golden-vector query tests.
- **Background writes the Swift 6 way**: a `@ModelActor` importer taking Sendable inputs, passing
  `PersistentIdentifier` across actors, never letting `ModelContext` or `@Model` escape.
- **Migrations without data loss**: `VersionedSchema` plus `SchemaMigrationPlan`, `propertiesToFetch`, a
  test that asserts no data is lost.
- **When not SwiftData**: the Core Data coexistence checklist, the iOS 17 floor as the decision boundary,
  the `@Attribute(.codable)` escape hatch and its caveats.

Add a recipe with `/new-recipe 04-persistence-swiftdata <slug>`.
