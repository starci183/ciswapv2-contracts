#[test_only]
module swap::package_manager_tests {
    //uses
    use std::signer::{ Self };
    use swap::package_manager::{ Self };
    use std::string::{ Self };

    //tests
    #[test(deployer = @deployer, resource_account = @swap)]
    public fun test_can_get_signer(deployer: &signer, resource_account: &signer) {
        package_manager::initialize_for_test(deployer, resource_account);
        let deployer_addr = signer::address_of(deployer);
        assert!(signer::address_of(&package_manager::get_signer()) != deployer_addr, 0);
    }

    #[test(deployer = @deployer, resource_account = @swap)]
    public fun test_can_set_and_get_address(deployer: &signer, resource_account: &signer) {
        package_manager::initialize_for_test(deployer, resource_account);
        package_manager::add_address(string::utf8(b"test"), @0xdeadbeef);
        assert!(package_manager::get_address(string::utf8(b"test")) == @0xdeadbeef, 1);
    }
}