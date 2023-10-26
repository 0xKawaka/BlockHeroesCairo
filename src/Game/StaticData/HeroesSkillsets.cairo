use core::array::ArrayTrait;
use core::dict::Felt252DictTrait;
use nullable::nullable_from_box;

fn createHeroesSkillsets() -> Felt252Dict<Nullable<Span<felt252>>> {
    let mut heroesSkillsets: Felt252Dict<Nullable<Span<felt252>>> = Default::default();
    // let skillset = array!['pbasic', 'spell1', 'spell2'];
    heroesSkillsets.insert('priest', nullable_from_box(BoxTrait::new(array!['pbasic', 'pspell1', 'pspell2'].span())));
    heroesSkillsets.insert('knight', nullable_from_box(BoxTrait::new(array!['kbasic', 'kspell1', 'kspell2'].span())));

    return heroesSkillsets;
}