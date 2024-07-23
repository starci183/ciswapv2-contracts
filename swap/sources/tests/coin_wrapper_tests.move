#[test_only]
module swap::coin_wrapper_tests {
    
    use aptos_framework::account::{ Self };
    use swap::coin_wrapper::{ Self };
    use swap::package_manager::{ Self };
    use aptos_framework::coin::{ Self };
    use aptos_framework::managed_coin::{ Self };
    use aptos_framework::fungible_asset::{ Self };
    use aptos_framework::object::{Self};
    use std::signer;

    struct CoinType {}

    const TEST_AMOUNT: u64 = 1000000000;

    #[test(deployer = @deployer, resource_account = @swap)]
    public fun test_can_initialize(deployer: &signer,  resource_account: &signer) {
        package_manager::initialize_for_test(deployer, resource_account);
        coin_wrapper::initialize();
        assert!(coin_wrapper::is_initialized(), 1);
    }

    #[test(deployer = @deployer, resource_account = @swap, user=@0xc0ffee)]
    public fun test_can_wrap_coin(deployer: &signer,  resource_account: &signer, user: &signer) {
        package_manager::initialize_for_test(deployer, resource_account);
        coin_wrapper::initialize();

        managed_coin::initialize<CoinType>(
            resource_account,
            b"USD Tether",
            b"USDT",
            9,
            true
        );

        account::create_account_for_test(signer::address_of(user));
        managed_coin::register<CoinType>(user);
        managed_coin::mint<CoinType>(resource_account, signer::address_of(user), TEST_AMOUNT);

        let coins = coin::withdraw<CoinType>(user, TEST_AMOUNT);
        let fa = coin_wrapper::wrap<CoinType>(coins);

        let metadata = fungible_asset::asset_metadata(&fa);

        assert!(fungible_asset::amount(&fa) == TEST_AMOUNT, 0);
        assert!(fungible_asset::name(metadata) == coin::name<CoinType>(), 0);
        assert!(fungible_asset::symbol(metadata) == coin::symbol<CoinType>(), 0);
        assert!(fungible_asset::decimals(metadata) == coin::decimals<CoinType>(), 0);

        let constructor_ref = &object::create_object_from_account(user);
        let store = fungible_asset::create_store(constructor_ref, metadata);
        fungible_asset::deposit(store, fa);

        assert!(fungible_asset::balance(store) == TEST_AMOUNT, 0);
    }

    #[test(deployer = @deployer, resource_account = @swap, user=@0xc0ffee)]
    public fun test_can_unwrap_coin(deployer: &signer,  resource_account: &signer, user: &signer) {
        package_manager::initialize_for_test(deployer, resource_account);
        coin_wrapper::initialize();

        managed_coin::initialize<CoinType>(
            resource_account,
            b"USD Tether",
            b"USDT",
            9,
            true
        );

        account::create_account_for_test(signer::address_of(user));
        managed_coin::register<CoinType>(user);
        managed_coin::mint<CoinType>(resource_account, signer::address_of(user), TEST_AMOUNT);

        let coins = coin::withdraw<CoinType>(user, TEST_AMOUNT);
        let fa = coin_wrapper::wrap<CoinType>(coins);

        let coins = coin_wrapper::unwrap<CoinType>(fa);
        coin::deposit<CoinType>(signer::address_of(user), coins);
        assert!(coin::balance<CoinType>(signer::address_of(user)) == TEST_AMOUNT, 0);
    }   
}