import FlowBetPalace from 0x01
import FlowToken from 0x05
transaction(amount: UFix64,uuid: String,optionIndex:UInt64) {
    prepare(acct: AuthAccount) {
    
        //extract money to pay the bet
        //
        // Get a reference to the signer's stored vault
        let vaultRef = acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
			?? panic("Could not borrow reference to the owner's Vault!")

        // Withdraw tokens from the signer's stored vault
        let vault <- vaultRef.withdraw(amount: amount)

        // extract Profile resource of the account
        let profile <- acct.load<@FlowBetPalace.UserSwitchboard>(from: FlowBetPalace.userSwitchBoardStoragePath) ?? panic("user have not started his account")

        // get admin account that stores resourced
        let accountFlowBetPalace = getAccount(0x01)

        // get reference of the childBet resource
        let childBetRef = accountFlowBetPalace.getCapability<&AnyResource{FlowBetPalace.ChildBetPublicInterface}>(PublicPath(identifier:"betchild".concat(uuid))!)
                            .borrow() ?? panic("invalid childBet uuid")

        //create the UserBet
        let newUserBet <- childBetRef.newBet(optionIndex: optionIndex, vault: <-vault)

        //add bet to the switchboard
        profile.addBet(newBet: <-newUserBet)

        // save the extracted resource
        // We use the force-unwrap operator `!` to get the value
        // out of the optional. It aborts if the optional is nil
        acct.save(<-profile!,to:FlowBetPalace.userSwitchBoardStoragePath)
    }

    execute {
    }
}