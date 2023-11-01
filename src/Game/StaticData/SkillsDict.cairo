use core::traits::Index;
use core::dict::Felt252DictTrait;
use super::super::Battle::Entity::{Skill, Skill::TargetType};
use super::super::Battle::Entity::Skill::Buff;
use super::super::Battle::Entity::Skill::Buff::{BuffType};

fn createSkillsDict() -> Felt252Dict<Nullable<Skill::Skill>> {
    let mut dict: Felt252Dict<Nullable<Skill::Skill>> = Default::default();
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
                        Skill::Heal::new(0, false, false, false, Skill::Heal::HealType::Percent),
                        TargetType::Enemy,
                        1,
                        array![].span(),
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
                        3,
                        Skill::Damage::new(0, false, false, false, Skill::Damage::DamageType::Flat),
                        Skill::Heal::new(10, false, true, false, Skill::Heal::HealType::Percent),
                        TargetType::Ally,
                        1,
                        array![Buff::new(BuffType::Regen, 10, 2, false, true, false)].span(),
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
                        2,
                        Skill::Damage::new(0, false, false, false, Skill::Damage::DamageType::Flat),
                        Skill::Heal::new(0, false, false, false, Skill::Heal::HealType::Percent),
                        TargetType::Ally,
                        1,
                        array![Buff::new(BuffType::DefenseUp, 100, 3, true, false, true)].span(),

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
                        Skill::Heal::new(0, false, false, false, Skill::Heal::HealType::Percent),
                        TargetType::Enemy,
                        1,
                        array![].span(),
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
                        Skill::Damage::new(20, true, false, false, Skill::Damage::DamageType::Flat),
                        Skill::Heal::new(0, false, false, false, Skill::Heal::HealType::Percent),
                        TargetType::Enemy,
                        1,
                        array![Buff::new(BuffType::Stun, 0, 2, true, false, false)].span(),
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
                        Skill::Damage::new(20, true, false, false, Skill::Damage::DamageType::Flat),
                        Skill::Heal::new(0, false, false, false, Skill::Heal::HealType::Percent),
                        TargetType::Enemy,
                        1,
                        array![Buff::new(BuffType::Poison, 20, 2, true, false, false)].span(),
                    )
                )
            )
        );
    
    dict
        .insert(
            'AttackHunter',
            nullable_from_box(
                BoxTrait::new(
                    Skill::new(
                        'AttackHunter',
                        'AttackHunter',
                        1,
                        Skill::Damage::new(10, true, false, false, Skill::Damage::DamageType::Flat),
                        Skill::Heal::new(0, false, false, false, Skill::Heal::HealType::Percent),
                        TargetType::Enemy,
                        1,
                        array![].span(),
                    )
                )
            )
        );

    dict
        .insert(
            'Arrows Rain',
            nullable_from_box(
                BoxTrait::new(
                    Skill::new(
                        'Arrows Rain',
                        'Arrows Rain',
                        1,
                        Skill::Damage::new(0, false, true, false, Skill::Damage::DamageType::Flat),
                        Skill::Heal::new(0, false, false, false, Skill::Heal::HealType::Percent),
                        TargetType::Enemy,
                        1,
                        array![Buff::new(BuffType::Poison, 15, 2, false, true, false)].span(),
                    )
                )
            )
        );

    dict
        .insert(
            'Forest Senses',
            nullable_from_box(
                BoxTrait::new(
                    Skill::new(
                        'Forest Senses',
                        'Forest Senses',
                        1,
                        Skill::Damage::new(0, false, false, false, Skill::Damage::DamageType::Flat),
                        Skill::Heal::new(0, false, false, false, Skill::Heal::HealType::Percent),
                        TargetType::Ally,
                        1,
                        array![Buff::new(BuffType::AttackUp, 100, 2, false, false, true), Buff::new(BuffType::SpeedUp, 100, 2, false, false, true)].span(),
                    )
                )
            )
        );
    
    dict
        .insert(
            'AttackAssassin',
            nullable_from_box(
                BoxTrait::new(
                    Skill::new(
                        'AttackAssassin',
                        'AttackAssassin',
                        1,
                        Skill::Damage::new(10, true, false, false, Skill::Damage::DamageType::Flat),
                        Skill::Heal::new(0, false, false, false, Skill::Heal::HealType::Percent),
                        TargetType::Enemy,
                        1,
                        array![].span(),
                    )
                )
            )
        );

    dict
        .insert(
            'Sand Strike',
            nullable_from_box(
                BoxTrait::new(
                    Skill::new(
                        'Sand Strike',
                        'Sand Strike',
                        1,
                        Skill::Damage::new(20, true, false, false, Skill::Damage::DamageType::Flat),
                        Skill::Heal::new(0, false, false, false, Skill::Heal::HealType::Percent),
                        TargetType::Enemy,
                        1,
                        array![Buff::new(BuffType::AttackUp, 30, 2, false, false, true)].span(),
                    )
                )
            )
        );

    dict
        .insert(
            'Sandstorm',
            nullable_from_box(
                BoxTrait::new(
                    Skill::new(
                        'Sandstorm',
                        'Sandstorm',
                        1,
                        Skill::Damage::new(10, false, true, false, Skill::Damage::DamageType::Flat),
                        Skill::Heal::new(0, false, false, false, Skill::Heal::HealType::Percent),
                        TargetType::Enemy,
                        1,
                        array![Buff::new(BuffType::SpeedDown, 20, 2, false, true, false)].span(),
                    )
                )
            )
        );


    return dict;
}
