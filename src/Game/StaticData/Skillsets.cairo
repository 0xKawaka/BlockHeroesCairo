use core::array::ArrayTrait;
use core::dict::Felt252DictTrait;
use nullable::nullable_from_box;

fn createSkillsets() -> Felt252Dict<Nullable<Span<felt252>>> {
    let mut heroesSkillsets: Felt252Dict<Nullable<Span<felt252>>> = Default::default();
    heroesSkillsets
        .insert(
            'priest',
            nullable_from_box(
                BoxTrait::new(array!['AttackPriest', 'Water Heal', 'Water Shield'].span())
            )
        );
    heroesSkillsets
        .insert(
            'knight',
            nullable_from_box(
                BoxTrait::new(array!['AttackKnight', 'Fire Swing', 'Fire Strike'].span())
            )
        );
    heroesSkillsets
        .insert(
            'assassin',
            nullable_from_box(
                BoxTrait::new(array!['AttackAssassin', 'Sand Strike', 'Sandstorm'].span())
            )
        );
    heroesSkillsets
        .insert(
            'Hunter',
            nullable_from_box(
                BoxTrait::new(array!['AttackHunter', 'Forest Senses', 'Arrows Rain'].span())
            )
        );
    return heroesSkillsets;
}
