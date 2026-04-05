import '../../../domain/entities/pet.dart';

/// Dados mock de animais para desenvolvimento e testes.
///
/// Estes dados simulam o que seria retornado pelo Firestore
/// na versão com Firebase integrado.
abstract final class MockPetsData {
  static List<Pet> get pets => [
        Pet(
          id: 'pet_001',
          ownerId: 'user_002',
          name: 'Thor',
          species: PetSpecies.dog,
          breed: 'Labrador',
          age: '2 anos',
          gender: PetGender.male,
          size: PetSize.large,
          energyLevel: PetEnergyLevel.high,
          healthInfo: const PetHealthInfo(
            vaccinated: true,
            neutered: true,
            dewormed: true,
          ),
          description:
              'Thor é um cachorro extremamente dócil e brincalhão. Adora crianças e convive bem com outros animais. Está acostumado a viver em apartamento, mas ama passeios longos no parque. Resgatado há 6 meses, já está totalmente adaptado à vida doméstica.',
          photos: [
            'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=800',
            'https://images.unsplash.com/photo-1552053831-71594a27632d?w=800',
          ],
          city: 'São Paulo',
          state: 'SP',
          status: PetStatus.available,
          createdAt: DateTime(2026, 3, 15),
        ),
        Pet(
          id: 'pet_002',
          ownerId: 'user_003',
          name: 'Luna',
          species: PetSpecies.cat,
          breed: 'Vira-lata',
          age: '1 ano',
          gender: PetGender.female,
          size: PetSize.small,
          energyLevel: PetEnergyLevel.medium,
          healthInfo: const PetHealthInfo(
            vaccinated: true,
            neutered: true,
            dewormed: true,
          ),
          description:
              'Luna é uma gatinha muito carinhosa e curiosa. Adora ficar no colo e observar o mundo pela janela. Ideal para apartamentos. Convive bem com outros gatos, mas prefere ser a única felina da casa.',
          photos: [
            'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=800',
            'https://images.unsplash.com/photo-1573865526739-10659fec78a5?w=800',
          ],
          city: 'Rio de Janeiro',
          state: 'RJ',
          status: PetStatus.available,
          createdAt: DateTime(2026, 3, 20),
        ),
        Pet(
          id: 'pet_003',
          ownerId: 'user_002',
          name: 'Bob',
          species: PetSpecies.dog,
          breed: 'Beagle',
          age: '4 anos',
          gender: PetGender.male,
          size: PetSize.medium,
          energyLevel: PetEnergyLevel.medium,
          healthInfo: const PetHealthInfo(
            vaccinated: true,
            neutered: false,
            dewormed: true,
            specialNeeds: ['Dieta especial para alergias'],
          ),
          description:
              'Bob é um beagle tranquilo e afetuoso. Já passou por um lar anterior e precisa de uma família paciente e carinhosa. Adora dormir e passear. Tem leve alergia alimentar, mas é fácil de cuidar.',
          photos: [
            'https://images.unsplash.com/photo-1505628346881-b72b27e84530?w=800',
          ],
          city: 'São Paulo',
          state: 'SP',
          status: PetStatus.available,
          createdAt: DateTime(2026, 3, 25),
        ),
        Pet(
          id: 'pet_004',
          ownerId: 'user_004',
          name: 'Mia',
          species: PetSpecies.cat,
          breed: 'Siamês',
          age: '3 anos',
          gender: PetGender.female,
          size: PetSize.small,
          energyLevel: PetEnergyLevel.low,
          healthInfo: const PetHealthInfo(
            vaccinated: true,
            neutered: true,
            dewormed: true,
          ),
          description:
              'Mia é uma gata siamesa elegante e tranquila. Perfeita para quem busca um companheiro calmo e independente. Adora um cantinho aconchegante e música suave. Não convive bem com cães.',
          photos: [
            'https://images.unsplash.com/photo-1596854407944-bf87f6fdd49e?w=800',
            'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=800',
          ],
          city: 'Belo Horizonte',
          state: 'MG',
          status: PetStatus.available,
          createdAt: DateTime(2026, 4, 1),
        ),
        Pet(
          id: 'pet_005',
          ownerId: 'user_003',
          name: 'Rex',
          species: PetSpecies.dog,
          breed: 'Pastor Alemão',
          age: '5 anos',
          gender: PetGender.male,
          size: PetSize.large,
          energyLevel: PetEnergyLevel.high,
          healthInfo: const PetHealthInfo(
            vaccinated: true,
            neutered: true,
            dewormed: true,
          ),
          description:
              'Rex é um pastor alemão leal e inteligente. Precisa de espaço para se exercitar e de um tutor experiente com cães de grande porte. Muito protetor e obediente. Ideal para casas com quintal.',
          photos: [
            'https://images.unsplash.com/photo-1589941013453-ec89f33b5e95?w=800',
          ],
          city: 'Curitiba',
          state: 'PR',
          status: PetStatus.available,
          createdAt: DateTime(2026, 4, 2),
        ),
        Pet(
          id: 'pet_006',
          ownerId: 'user_004',
          name: 'Mel',
          species: PetSpecies.dog,
          breed: 'Vira-lata',
          age: '8 meses',
          gender: PetGender.female,
          size: PetSize.medium,
          energyLevel: PetEnergyLevel.high,
          healthInfo: const PetHealthInfo(
            vaccinated: true,
            neutered: false,
            dewormed: true,
          ),
          description:
              'Mel é uma filhote cheia de vida e alegria! Aprende rápido e adora brincar. Está em fase de socialização e se adapta bem a qualquer ambiente. Vai trazer muita felicidade para a família que a adotar.',
          photos: [
            'https://images.unsplash.com/photo-1561037404-61cd46aa615b?w=800',
            'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=800',
          ],
          city: 'São Paulo',
          state: 'SP',
          status: PetStatus.available,
          createdAt: DateTime(2026, 4, 3),
        ),
      ];
}
