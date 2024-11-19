use starknet::ContractAddress;
use puppet_vs_gizmo::models::{Game, Player};

#[starknet::interface]
trait IActions<T> {
    fn create_game(ref self: T, character: u8, game_id: u8);
    fn join_game(ref self: T, game_id: u8);
    fn throw(ref self: T, game_id: u8, power: u8);
}

#[dojo::contract]
pub mod actions {
    use super::IActions;
    use starknet::{ContractAddress, get_caller_address};
    use puppet_vs_gizmo::models::{Game, Player};

    use dojo::model::{ModelStorage, ModelValueStorage};
    use dojo::event::EventStorage;

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {

        fn create_game(ref self: ContractState, character: u8, game_id: u8) {
            let mut world = self.world_default();

            let caller = get_caller_address();
            
            let player_2 = caller;

            let mut turn = 1;
            
            let game = Game { player_1: caller, player_2, character, turn, winner: 0, wind: 0, game_id: game_id };

            let player = Player { address: caller, can_throw: true, hp: 100 };

            if game_id == 1 {
                panic!("Game ID already in use");
            }

            world.write_model(@game);
            world.write_model(@player);
        } 

        fn join_game(ref self: ContractState, game_id: u8) {
            let mut world = self.world_default();

            let caller = get_caller_address();

            let mut game: Game = world.read_model(game_id);

            let zero = game.player_1;

            game.player_2 = caller;

            let player = Player { address: caller, can_throw: true, hp: 100 };

            if game.player_2 != zero {
                panic!("Game is full");
            }

            if game.player_1 == caller || game.player_2 == caller {
                panic!("Player already in game");
            }

            world.write_model(@game);
            world.write_model(@player);
        }

        fn throw(ref self: ContractState, game_id: u8, power: u8) {
            let mut world = self.world_default();

            let mut game: Game = world.read_model(game_id);

            let caller = get_caller_address();

            if game.turn == 1 {
                if game.player_1 == caller {
                    let mut player: Player = world.read_model(game.player_2);
                    let mut increment = 1;
                    
                    player.hp -= power;

                    game.turn += increment;
                    world.write_model(@player);
                } else {
                    panic!("Not your turn");
                }
            } else {
                if game.player_2 == caller {
                    let mut player: Player = world.read_model(game.player_1);
                    let mut decrement = 1;

                    player.hp -= power;

                    game.turn -= decrement;
                    world.write_model(@player);
                } else {
                    panic!("Not your turn");
                }
            }

            if game.player_1 != caller && game.player_2 != caller {
                panic!("Player is not in game");
            }
            
            world.write_model(@game);
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"puppet_vs_gizmo")
        }
    }

}
