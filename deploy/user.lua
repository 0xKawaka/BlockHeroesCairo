function send_tx(contract_address, function_name, call_data)
  local invk_res, err = invoke(
     {
        {
           to = contract_address,
           func = function_name,
           calldata = call_data,
        },
     },
     { watch_interval = 100 }
  )

  if err then
    print(err)
    os.exit(3)
  end

  print("Invoke " .. function_name .. " TX hash: " .. invk_res.tx_hash)
  return invk_res
end


RPC = "KATANA"

-- ACCOUNT_ADDRESS = "0x517ececd29116499f4a1b64b094da79ba08dfd54a3edaa316134c41f8160973"
-- ACCOUNT_PRIVKEY = "0x1800000000300000180000000000030000000000003006001800006600"
ACCOUNT_ADDRESS = "0x0330a584aeDC1a32BdC178068fcb279982A28FE7A43d73Cf78245E62329f205A"
ACCOUNT_PRIVKEY = "0x9a46d3b8e4fe4f5ec1984ab5c1390f418b1f9a03fb6f89c1edee4833381b82"
game_contract_address = "0x00c2e793f407c484e96596a56203690835efe5d2a74f51cf7f5040e386b54819"

local logger = logger_init()
send_tx(game_contract_address, "createAccount", { })
send_tx(game_contract_address, "mintHero", { })
send_tx(game_contract_address, "mintHero", { })
send_tx(game_contract_address, "mintHero", { })

-- local heroIds = {1, 2}
-- send_tx(game_contract_address, "startBattle", { {heroIds, 0, 1} })

-- local call_res, err = call(contract_address, "get_a", {}, {})
-- print_str_array(call_res)