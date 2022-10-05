pragma solidity ^0.8.17;
// SPDX-License-Identifier: UNLICENSED

import "openzeppelin-solidity/contracts/utils/Strings.sol";

contract Words {
    
    address public CONTRACT_OWNER;

    constructor() { CONTRACT_OWNER = msg.sender; }

    struct Word {
        address creator;
        address owner;
        string  word;
        bool    on_sale;
        uint256 price;
        uint256 likes;
        uint256 dislikes;
    }
    

    mapping(uint256 =>    Word) private words_list;
    mapping(string  =>    bool) private written_words;
    mapping(address => uint256) private n_words_by_wallet;
    mapping(address => uint256) private votes_by_wallet;

    uint256 public PRICE = 1000000000000000;     // 0.001 ETH expressed in wei
    uint256 public CREATOR_QUOTA = 25;
    uint8   public MAX_QUANTITY  = 3;            // Maximum allowed quantity of words per wallet and votes per wallet
    uint256 public total_words_count = 0;


    // Actions
    function write_word(string memory word) public payable returns(bool) {

        // Write word in the words_list array
        words_list[total_words_count] = Word(msg.sender, msg.sender, word, false, 0, 0, 0);

        // Update counters
        total_words_count += 1;
        n_words_by_wallet[msg.sender] += 1;

        // Require payment of 0.001 ETH
        require(msg.value==PRICE, "The price is 0.001 ETH per word");

        // Enforce the maximum number of words per wallet
        require(n_words_by_wallet[msg.sender]<=MAX_QUANTITY, "Max 3 words per wallet");

        return true;
    }

    function like_word(uint256 word_id) public {
        require(votes_by_wallet[msg.sender]<MAX_QUANTITY, "Max 3 votes per wallet");
        words_list[word_id].likes += 1;
        votes_by_wallet[msg.sender] += 1;
    }

    function dislike_word(uint256 word_id) public {
        require(votes_by_wallet[msg.sender]<MAX_QUANTITY, "Max 3 votes per wallet");
        words_list[word_id].dislikes += 1;
        votes_by_wallet[msg.sender] += 1;
    }


    // Views
    function read_word(uint256 word_id) public view returns(string memory) {
        return words_list[word_id].word;
    }

    function word_count_by_address(address address_) public view returns(uint256) {
        return n_words_by_wallet[address_];
    }

    function owner_of_word(uint256 word_id) public view returns(address) {
        return words_list[word_id].owner;
    }

    function creator_of_word(uint256 word_id) public view returns(address) {
        return words_list[word_id].creator;
    }

    function likes_of_word(uint256 word_id) public view returns(uint256) {
        return words_list[word_id].likes;
    }

    function dislikes_of_word(uint256 word_id) public view returns(uint256) {
        return words_list[word_id].dislikes;
    }


    // Market
    function list_word_for_sale(uint256 word_id, uint256 price) public {
        require(msg.sender==words_list[word_id].owner);
        words_list[word_id].on_sale = true;
        words_list[word_id].price   = price;
    }

    function cancel_listing(uint256 word_id) public {
        require(msg.sender==words_list[word_id].owner);
        words_list[word_id].on_sale = false;
        words_list[word_id].price   = 0;
    }

    function is_on_sale(uint256 word_id) public view returns(bool){
        return bool(words_list[word_id].on_sale);
    }

    function list_price(uint256 word_id) public view returns(uint256){
        require(words_list[word_id].on_sale, "Word not on sale");
        return words_list[word_id].price;
    }

    function buy_word(uint256 word_id) public payable {

        Word memory word = words_list[word_id];

        require(msg.sender!=word.owner, "The buyer cannot be the owner");
        require(msg.value==word.price, "You should pay the listed price for this word");
        
        if (word.owner==word.creator) {
            payable(word.owner).transfer(word.price);
        } else {
            uint256 amount = uint256(word.price * CREATOR_QUOTA / 100);
            payable(word.creator).transfer(amount);
            payable(word.owner  ).transfer(word.price - amount);
        }

        words_list[word_id].owner = msg.sender;
        cancel_listing(word_id);

    }

    function withdraw(address payable recipient, uint256 amount) external {
        require(msg.sender ==  CONTRACT_OWNER, "Only the contract owner can withdraw funds!");
        recipient.transfer(amount);
    }

    function delete_word(uint256 word_id) external {
        require(msg.sender ==  CONTRACT_OWNER, "Only the contract owner can delete words");
        words_list[word_id].word = "";
    }

}