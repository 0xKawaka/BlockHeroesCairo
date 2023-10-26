use super::super::Battle::Entity::Skill;

fn createSkillsDict() -> Felt252Dict<Nullable<Skill::Skill>> {
    let mut dict: Felt252Dict<Nullable<Skill::Skill>> = Default::default();
    // name: felt252, description: felt252, cooldown: u16, damage: Damage, heal: Heal, targetType: felt252, accuracy: u16,
    dict.insert('pbasic', nullable_from_box(BoxTrait::new(Skill::new('pbasic', 'pbasic', 1,
    Skill::Damage::new(Skill::Damage::DamageType::Flat),
    Skill::Heal::new(Skill::Heal::HealType::Percent),
    1, 1))));
    dict.insert('pspell1', nullable_from_box(BoxTrait::new(Skill::new('pspell1', 'pspell1', 1,
    Skill::Damage::new(Skill::Damage::DamageType::Flat),
    Skill::Heal::new(Skill::Heal::HealType::Percent),
    1, 1))));
    dict.insert('pspell2', nullable_from_box(BoxTrait::new(Skill::new('pspell2', 'pspell2', 1,
    Skill::Damage::new(Skill::Damage::DamageType::Flat),
    Skill::Heal::new(Skill::Heal::HealType::Percent),
    1, 1))));
    dict.insert('kbasic', nullable_from_box(BoxTrait::new(Skill::new('kbasic', 'kbasic', 1,
    Skill::Damage::new(Skill::Damage::DamageType::Flat),
    Skill::Heal::new(Skill::Heal::HealType::Percent),
    1, 1))));
    dict.insert('kspell1', nullable_from_box(BoxTrait::new(Skill::new('kspell1', 'kspell1', 1,
    Skill::Damage::new(Skill::Damage::DamageType::Flat),
    Skill::Heal::new(Skill::Heal::HealType::Percent),
    1, 1))));
    dict.insert('kspell2', nullable_from_box(BoxTrait::new(Skill::new('kspell2', 'kspell2', 1,
    Skill::Damage::new(Skill::Damage::DamageType::Flat),
    Skill::Heal::new(Skill::Heal::HealType::Percent),
    1, 1))));
    return dict;
}