module hippo_aggregator::devnet {
    use coin_list::devnet_coins::{DevnetBTC as BTC, DevnetUSDC as USDC, mint_to_wallet};
    use std::signer::address_of;
    use std::string::utf8;

    const BTC_AMOUNT: u64 = 100000000 * 1000;
    const USDC_AMOUNT: u64 = 100000000 * 1000 * 10000;
    struct PontemLP<phantom X, phantom Y> {}
    struct PontemLP2<phantom X, phantom Y, phantom curve> {}

    #[cmd(desc=b"Create BTC-USDC pool on pontem and add liquidity")]
    public entry fun mock_deploy_pontem(admin: signer) {
        use liquidswap::scripts;
        use liquidswap::curves;
        // BTC-USDC pair
        mint_to_wallet<BTC>(&admin, BTC_AMOUNT);
        mint_to_wallet<USDC>(&admin, USDC_AMOUNT);
        scripts::register_pool_and_add_liquidity<BTC, USDC, curves::Uncorrelated>(
            &admin,
            BTC_AMOUNT,
            BTC_AMOUNT,
            USDC_AMOUNT,
            USDC_AMOUNT
        )
    }

    #[cmd(desc=b"Create BTC-USDC pool on econia and add liquidity")]
    public entry fun mock_deploy_econia(admin: signer, market_id: u64) {
        use econia::market;
        use econia::user;
        let lot_size: u64 = 1000;
        let tick_size: u64 = 1000;
        market::register_market_pure_coin<BTC, USDC>(&admin, lot_size, tick_size);
        user::register_market_account<BTC, USDC>(&admin, market_id, 0);
        mint_to_wallet<BTC>(&admin, BTC_AMOUNT);
        mint_to_wallet<USDC>(&admin, USDC_AMOUNT);
        user::deposit_from_coinstore<BTC>(&admin, market_id, 0, BTC_AMOUNT);
        user::deposit_from_coinstore<USDC>(&admin, market_id, 0, USDC_AMOUNT);
        market::place_limit_order_user<BTC, USDC>(&admin, address_of(&admin), market_id, true, BTC_AMOUNT / lot_size, 10001 * (lot_size / tick_size), true, false, false);
        market::place_limit_order_user<BTC, USDC>(&admin, address_of(&admin), market_id, false, BTC_AMOUNT / lot_size, 10000 * (lot_size / tick_size), true, false, false);
    }

    #[cmd(desc=b"Create BTC-USDC pool on econia and add liquidity")]
    public entry fun mock_deploy_basiq(admin: &signer) {
        use basiq::dex;
        mint_to_wallet<BTC>(admin, BTC_AMOUNT);
        mint_to_wallet<USDC>(admin, USDC_AMOUNT);
        dex::admin_create_pool<BTC, USDC>(
            admin,
            USDC_AMOUNT / BTC_AMOUNT * 1000000,
            1 * 1000000,
            utf8(b"BTC-USDC LP"),
            utf8(b"BTC-USDC"),
            true,
        );
        dex::add_liquidity_entry<BTC, USDC>(admin, BTC_AMOUNT, USDC_AMOUNT);
    }

    public entry fun registe_coins(hippo_swap: &signer, coin_list: &signer, deploy_coin_list:bool){
        let _hippo_swap = hippo_swap;
        let _coin_list = coin_list;
        let _deploy_coin_list = deploy_coin_list;
    }
}
