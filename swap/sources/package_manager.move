module swap::package_manager {
    //uses
    use aptos_framework::account::{ Self, SignerCapability };
    use aptos_framework::resource_account::{ Self };
    use aptos_std::smart_table::{ Self, SmartTable };
    use std::string::{ String };

    friend swap::coin_wrapper;
    #[test_only]
    use aptos_framework::account::{ create_account_for_test };
    #[test_only]
    use std::signer::{ Self };

    //structs
    struct PermissionConfig has key {
        signer_cap: SignerCapability,
        addresses: SmartTable<String, address>,
    }

    //functions
    fun init_module(resource_signer: &signer) {
        let signer_cap = resource_account::retrieve_resource_account_cap(resource_signer, @deployer);
        move_to(resource_signer, PermissionConfig {
            addresses: smart_table::new<String, address>(),
            signer_cap,
        });
    }

    public(friend) fun get_signer(): signer acquires PermissionConfig {
        let signer_cap = &borrow_global<PermissionConfig>(@swap).signer_cap;
        account::create_signer_with_capability(signer_cap)
    }

    public(friend) fun add_address(name: String, object: address) acquires PermissionConfig {
        let addresses = &mut borrow_global_mut<PermissionConfig>(@swap).addresses;
        smart_table::add(addresses, name, object);
    }

    public fun address_exists(name: String): bool acquires PermissionConfig {
        smart_table::contains(&safe_permission_config().addresses, name)
    }

    public fun get_address(name: String): address acquires PermissionConfig {
        let addresses = &borrow_global<PermissionConfig>(@swap).addresses;
        *smart_table::borrow(addresses, name)
    }

    inline fun safe_permission_config(): &PermissionConfig acquires PermissionConfig {
        borrow_global<PermissionConfig>(@swap)
    }

    //setup tests
    #[test_only]
    public(friend) fun initialize_for_test(deployer: &signer, resource_signer: &signer) {
        create_account_for_test(signer::address_of(deployer));
        resource_account::create_resource_account(deployer, b"", b"");
        init_module(resource_signer);
    }

    #[test_only]
    friend swap::package_manager_tests;
    #[test_only]
    friend swap::coin_wrapper_tests;
}
