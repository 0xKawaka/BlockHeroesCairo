use super::super::Battle::Entity::Skill;

fn createSkillsDict() -> Felt252Dict<Nullable<Skill::Skill>> {
    let mut dict: Felt252Dict<Nullable<Skill::Skill>> = Default::default();
    // name: felt252, description: felt252, cooldown: u16, damage: Damage, heal: Heal, targetType: felt252, accuracy: u16,
    dict
        .insert(
            'AttackPriest',
            nullable_from_box(
                BoxTrait::new(
                    Skill::new(
                        'AttackPriest',
                        'AttackPriest',
                        1,
                        Skill::Damage::new(10, true, false, false, Skill::Damage::DamageType::Flat),
                        Skill::Heal::new(10, true, false, false, Skill::Heal::HealType::Percent),
                        1,
                        1
                    )
                )
            )
        );
    dict
        .insert(
            'Water Heal',
            nullable_from_box(
                BoxTrait::new(
                    Skill::new(
                        'Water Heal',
                        'Water Heal',
                        1,
                        Skill::Damage::new(10, true, false, false, Skill::Damage::DamageType::Flat),
                        Skill::Heal::new(10, true, false, false, Skill::Heal::HealType::Percent),
                        1,
                        1
                    )
                )
            )
        );
    dict
        .insert(
            'Water Shield',
            nullable_from_box(
                BoxTrait::new(
                    Skill::new(
                        'Water Shield',
                        'Water Shield',
                        1,
                        Skill::Damage::new(10, true, false, false, Skill::Damage::DamageType::Flat),
                        Skill::Heal::new(10, true, false, false, Skill::Heal::HealType::Percent),
                        1,
                        1
                    )
                )
            )
        );
    dict
        .insert(
            'AttackKnight',
            nullable_from_box(
                BoxTrait::new(
                    Skill::new(
                        'AttackKnight',
                        'AttackKnight',
                        1,
                        Skill::Damage::new(10, true, false, false, Skill::Damage::DamageType::Flat),
                        Skill::Heal::new(10, true, false, false, Skill::Heal::HealType::Percent),
                        1,
                        1
                    )
                )
            )
        );
    dict
        .insert(
            'Fire Swing',
            nullable_from_box(
                BoxTrait::new(
                    Skill::new(
                        'Fire Swing',
                        'Fire Swing',
                        1,
                        Skill::Damage::new(10, true, false, false, Skill::Damage::DamageType::Flat),
                        Skill::Heal::new(10, true, false, false, Skill::Heal::HealType::Percent),
                        1,
                        1
                    )
                )
            )
        );
    dict
        .insert(
            'Fire Strike',
            nullable_from_box(
                BoxTrait::new(
                    Skill::new(
                        'Fire Strike',
                        'Fire Strike',
                        1,
                        Skill::Damage::new(10, true, false, false, Skill::Damage::DamageType::Flat),
                        Skill::Heal::new(10, true, false, false, Skill::Heal::HealType::Percent),
                        1,
                        1
                    )
                )
            )
        );
    return dict;
}
