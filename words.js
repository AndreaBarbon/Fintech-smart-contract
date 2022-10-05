const { expect } = require("chai")


describe("Words contract", function () {

  var contract
  const PRICE = 1000000000000000 // 0.001 ETH

  before(async function () {

      const accounts = await hre.ethers.getSigners()
      const deployer = accounts[0]
      const buyer    = accounts[1]

      const Words = await ethers.getContractFactory("Words")
      const words = await Words.deploy()
      await words.deployed()
      contract  = words.connect(deployer)
      contract2 = words.connect(buyer)

  })

  // Words

    it("Write two words", async function () {

      const tx1 = await contract.write_word("Financial",  { value:PRICE } )
      const tx2 = await contract.write_word("Technology", { value:PRICE } )

    })

    it("Read the words", async function () {

      var word_id
      
      word_id = 0
      const tx1 = await contract.read_word(word_id)
      console.log(`   👉 Word in position ${word_id}: "${tx1}"`)

      word_id = 1
      const tx2 = await contract.read_word(word_id)
      console.log(`   👉 Word in position ${word_id}: "${tx2}"`)

    })


  // Votes

      it("Cast votes", async function () {
        
        const tx1   = await contract.like_word(0)
        const tx2   = await contract.like_word(1)

        const tx4   = await contract2.dislike_word(0)
        const tx3   = await contract2.like_word(1)

      })

      it("Read votes", async function () {
        
        var word, likes, dislikes, total

        word     = await contract.read_word(0)
        likes    = await contract.likes_of_word(0)
        dislikes = await contract.dislikes_of_word(0)
        total    = likes - dislikes
        console.log(`   👉 "${word}" totals ${total} votes`)

        word     = await contract.read_word(1)
        likes    = await contract.likes_of_word(1)
        dislikes = await contract.dislikes_of_word(1)
        total    = likes - dislikes
        console.log(`   👉 "${word}" totals ${total} votes`)

      })


  // Market

    it("List a word for sale", async function () {
      
      const word_id = 1
      const price   = 1500000000000000 // 0.0015 ETH
      const word    = await contract.read_word(word_id)
      const tx1     = await contract.list_word_for_sale(word_id, price)
      console.log(`   👉 "${word}" listed for ${price / 10**18} ETH`)

    })

    it("Query listing price", async function () {
      
      var word_id = 1
      var on_sale = await contract.is_on_sale(word_id)

      if (on_sale) {
        var price   = await contract.list_price(word_id)
        var word    = await contract.read_word(word_id)
      }

    })

    it("Buy a word", async function () {
      
      const word_id = 1
      const price   = await contract2.list_price(word_id)
      const tx1     = await contract2.buy_word(word_id,  { value:price } )

    })

    it("Read owners", async function () {
      
      var word_id = 0
      var word    = await contract.read_word(word_id)
      var owner   = await contract2.owner_of_word(word_id)
      console.log(`   👉 "${word}" is owned by ${owner}`)

      word_id = 1
      word    = await contract.read_word(word_id)
      owner   = await contract2.owner_of_word(word_id)
      console.log(`   👉 "${word}" is owned by ${owner}`)

    })

    it("Delete a word", async function () {
      
      const word_id = 1
      const tx2   = await contract.delete_word(word_id)
      console.log(`   👉 Word ${word_id} erased`)

    })

})