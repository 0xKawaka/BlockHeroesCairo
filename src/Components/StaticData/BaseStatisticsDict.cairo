use super::super::EntityFactory::BaseStatistics;

fn createBaseStatisticsDict() -> Felt252Dict<Nullable<BaseStatistics::BaseStatistics>> {
    let mut dict: Felt252Dict<Nullable<BaseStatistics::BaseStatistics>> = Default::default();
    dict
        .insert(
            'knight',
            nullable_from_box(BoxTrait::new(BaseStatistics::new(1000, 100, 100, 100, 20, 100)))
        );
    dict
        .insert(
            'priest',
            nullable_from_box(BoxTrait::new(BaseStatistics::new(2000, 200, 200, 102, 20, 150)))
        );
    dict
        .insert(
            'hunter',
            nullable_from_box(BoxTrait::new(BaseStatistics::new(3000, 300, 300, 103, 20, 300)))
        );
    return dict;
}
