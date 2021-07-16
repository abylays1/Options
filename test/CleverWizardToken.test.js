const Token = artifacts.require("CleverWizardToken");
const chaiobjects = require("./setupchai.js");
const chai = chaiobjects.chai;
const expect = chaiobjects.expect;
const BN = chaiobjects.BN;



contract("Token Test", function(accounts) {
    const [initialHolder, recepient, anotherAccount] = accounts;

    beforeEach(async() => {
        this.CLWZToken = await Token.new();
    });

    it("All tokens should be in my account", async() => {
        let instance = this.CLWZToken;
        let totalSupply = await instance.totalSupply();
        return await expect(instance.balanceOf(initialHolder)).to.eventually.be.a.bignumber.equal(totalSupply);
    });

    it("I can send tokens from Account 1 to Account 2", async() => {
        const sendTokens = 1;
        let instance = this.CLWZToken;
        let totalSupply = await instance.totalSupply();
        await expect(instance.balanceOf(initialHolder)).to.eventually.be.a.bignumber.equal(totalSupply);
        await expect(instance.transfer(recepient, sendTokens)).to.eventually.be.fulfilled;
        await expect(instance.balanceOf(initialHolder)).to.eventually.be.a.bignumber.equal(totalSupply.sub(new BN(sendTokens)));
        return await expect(instance.balanceOf(recepient)).to.eventually.be.a.bignumber.equal(new BN(sendTokens));
    });

    it("It's not possible to send more tokens than Account 1 has", async() => {
        let instance = this.CLWZToken;
        let balanceofAcccount = await instance.balanceOf(initialHolder);
        await expect(instance.transfer(recepient, new BN(balanceofAcccount + 1))).to.eventually.be.rejected;
        return await expect(instance.balanceOf(initialHolder)).to.eventually.be.a.bignumber.equal(balanceofAcccount);
    });

});