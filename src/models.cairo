use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Player {
    #[key]
    pub address: ContractAddress,
    pub can_throw: bool,
    pub hp: u8
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Game {
    #[key]
    pub game_id: u8,
    pub player_1: ContractAddress,
    pub player_2: ContractAddress,
    pub character: u8,
    pub turn: u8,
    pub winner: u8,
    pub wind: u8,
}