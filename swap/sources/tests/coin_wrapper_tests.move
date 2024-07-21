#[test_only]
module swap::coin_wrapper_tests {
    
    use swap::coin_wrapper::{ Self };
    use swap::package_manager::{ Self };
    use aptos_framework::managed_coin::{ Self };
    use aptos_framework::fungible_asset::{ Self, FungibleAsset };
    use aptos_framework::coin::{ Self, Coin };

    struct CoinType {}

    #[test(deployer = @deployer, resource_account = @swap)]
    public fun test_can_initialize(deployer: &signer,  resource_account: &signer) {
        package_manager::initialize_for_test(deployer, resource_account);
        coin_wrapper::initialize();
        assert!(coin_wrapper::is_initialized(), 1);
    }

    #[test(deployer = @deployer, resource_account = @swap)]
    public fun test_can_wrap_coin(deployer: &signer,  resource_account: &signer) {
        package_manager::initialize_for_test(deployer, resource_account);
        coin_wrapper::initialize();

        managed_coin::initialize<CoinType>(
            resource_account,
            b"USD Tether",
            b"USDT",
            9,
            true
        );

        managed_coin::register<CoinType>(deployer);
        managed_coin::mint<CoinType>(resource_account,  @deployer, 1000000000);

        let coins = coin::withdraw<CoinType>(deployer, 1000000000);
        let fa = coin_wrapper::wrap<CoinType>(coins);
    }   
}