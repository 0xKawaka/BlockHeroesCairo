RPC = "KATANA"
ACCOUNT_ADDRESS = "0x517ececd29116499f4a1b64b094da79ba08dfd54a3edaa316134c41f8160973"
ACCOUNT_PRIVKEY = "0x1800000000300000180000000000030000000000003006001800006600"

function declareAndDeploy(name)
  local decl_res, err = declare(name, { watch_interval = 100, artifacts_path = "../target/dev" })
  if err then
    print(err)
    os.exit(1)
  end
  print("Declared " .. name .. " class_hash: " .. decl_res.class_hash)

  -- Deploy with no constructor args.
  local depl_res, err = deploy(decl_res.class_hash, {}, { watch_interval = 100, salt = "0x1234" })

  if err then
    print(err)
    os.exit(2)
  end

  local contract_address = depl_res.deployed_address
  print("Contract "  .. name ..  " deployed at: " .. contract_address)
  return contract_address
end

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

local logger = logger_init()
local game_contract_address = declareAndDeploy("game_Game")
local levels_contract_address = declareAndDeploy("game_Levels")
local entityFactory_contract_address = declareAndDeploy("game_EntityFactory")
local accounts_contract_address = declareAndDeploy("game_Accounts")
local battles_contract_address = declareAndDeploy("game_Battles")

send_tx(game_contract_address, "setAccountsAdrs", { accounts_contract_address })
send_tx(game_contract_address, "setEntityFactoryAdrs", { entityFactory_contract_address })
send_tx(game_contract_address, "setLevelsAdrs", { levels_contract_address })
send_tx(game_contract_address, "setBattleAdrs", { battles_contract_address })
send_tx(game_contract_address, "createAccount", { })
send_tx(game_contract_address, "mintHero", { })
send_tx(game_contract_address, "mintHero", { })
send_tx(game_contract_address, "mintHero", { })

-- local heroIds = {1, 2}
-- send_tx(game_contract_address, "startBattle", { {heroIds, 0, 1} })

-- local call_res, err = call(contract_address, "get_a", {}, {})
-- print_str_array(call_res)
