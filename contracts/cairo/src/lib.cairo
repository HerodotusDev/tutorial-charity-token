#[starknet::interface]
trait IEvmFactsRegistry<TContractState> {
    fn get_slot_value(
        self: @TContractState, account: felt252, block: u256, slot: u256
    ) -> Option<u256>;
}

#[starknet::interface]
trait ICharityToken<TContractState> {
    fn claim(ref self: TContractState, account: felt252, block: u256, amount_slot: u256);
}

#[starknet::contract]
mod CharityToken {
    use core::traits::TryInto;
    use core::traits::Into;
    use core::option::OptionTrait;
    use openzeppelin::token::erc20::ERC20Component;
    use starknet::ContractAddress;
    use super::{IEvmFactsRegistryDispatcherTrait, IEvmFactsRegistryDispatcher};

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    #[abi(embed_v0)]
    impl ERC20Impl = ERC20Component::ERC20Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC20MetadataImpl = ERC20Component::ERC20MetadataImpl<ContractState>;
    #[abi(embed_v0)]
    impl SafeAllowanceImpl = ERC20Component::SafeAllowanceImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC20CamelOnlyImpl = ERC20Component::ERC20CamelOnlyImpl<ContractState>;
    #[abi(embed_v0)]
    impl SafeAllowanceCamelImpl =
        ERC20Component::SafeAllowanceCamelImpl<ContractState>;
    impl InternalImpl = ERC20Component::InternalImpl<ContractState>;

    const AIRDROP_ELIGIBILITY_THRESHOLD: u256 = 1000;
    const AIRDROP_DONATION_MULTIPLIER: u256 = 2;

    #[storage]
    struct Storage {
        herodotus_facts_registry: ContractAddress,
        //? account_address -> amount
        claimed_aidrop: LegacyMap::<felt252, Option<u256>>,
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.erc20.initializer('CharityToken', 'HER');
        self
            .erc20
            ._mint(
                0x0278619D391034A091b099C6Fd53A3Dc56859196f9aC67bE75B3AD3Bff4869f6
                    .try_into()
                    .unwrap(),
                69420
            );
        self
            .herodotus_facts_registry
            .write(
                0x01b2111317EB693c3EE46633edd45A4876db14A3a53ACDBf4E5166976d8e869d
                    .try_into()
                    .unwrap()
            );
    }

    #[external(v0)]
    impl CharityToken of super::ICharityToken<ContractState> {
        fn claim(ref self: ContractState, account: felt252, block: u256, amount_slot: u256) {
            let caller = starknet::get_caller_address();

            let claimer_slot = amount_slot + 1;
            let claimer = IEvmFactsRegistryDispatcher {
                contract_address: self.herodotus_facts_registry.read()
            }
                .get_slot_value(account, block, claimer_slot)
                .unwrap();

            let caller_felt: felt252 = caller.into();
            assert(caller_felt.into() == claimer, 'This isn\'t your airdrop!');

            let donation_amount: u256 = IEvmFactsRegistryDispatcher {
                contract_address: self.herodotus_facts_registry.read()
            }
                .get_slot_value(account, block, amount_slot)
                .unwrap();
            let airdrop_amount = donation_amount * AIRDROP_DONATION_MULTIPLIER;
            assert(donation_amount > AIRDROP_ELIGIBILITY_THRESHOLD, 'You haven\'t donated enough!');

            let already_claimed = match self.claimed_aidrop.read(account) {
                Option::Some(claimed_amount) => {
                    assert(claimed_amount < airdrop_amount, 'Claimed already!');
                    claimed_amount
                },
                Option::None => 0
            };

            self.erc20._mint(caller, airdrop_amount - already_claimed);
            self.claimed_aidrop.write(account, Option::Some(airdrop_amount));
        }
    }
}
