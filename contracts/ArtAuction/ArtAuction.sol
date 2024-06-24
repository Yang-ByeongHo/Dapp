pragma solidity ^0.4.26;

contract ArtAuction {

    uint public deadLine;

    // 미술품 정보를 나타내는 구조체
    struct Art {
        string name;  // 미술품 이름
        string description; // 설명
        uint startingPrice;  // 시작 가격
    }

    // 미술품 경매 정보를 나타내는 구조체
    struct Auction {
        address owner;  // 경매 소유자
        address highestBidder;  // 현재 최고 입찰자
        address winner;  // 낙찰자
        uint currentPrice;  // 현재 입찰 가격
        uint deadline;  // 경매 종료 시간 (Unix Time)
        bool ended;  // 경매 종료 여부
        string status;  // 경매 상태
    }

    // 미술품 id에 따른 미술품 정보 매핑
    mapping(uint => Art) public arts;
    // 미술품 id에 따른 경매 정보 매핑
    mapping(uint => Auction) public auctions;
    // 모든 미술품 id를 저장하는 배열
    uint[] public artIds;

    // 경매 내용을 기록하는 이벤트
    event NewArt(uint artId, string name, uint startingPrice, uint deadline);
    event AuctionEnded(uint artId, address winner, uint amount);

    // 경매 소유자에게만 허용하는 modifier
    modifier onlyOwner(uint _artId) {
        require(msg.sender == auctions[_artId].owner);
        _;
    }

    constructor (uint _deadLine) public {
        deadLine = now + _deadLine;
    }

    function createArt(uint _artId, string _name, uint _startingPrice, uint _duration, string _description) public {
        
        require(auctions[_artId].owner == address(0)); // artId 중복이면 X
        require(_startingPrice > 0);

        auctions[_artId] = Auction(msg.sender, address(0), address(0), _startingPrice * 1 ether, now + _duration, false, "경매가 진행중입니다.");
        arts[_artId] = Art(_name, _description, _startingPrice);
        artIds.push(_artId);  // 새로운 artId를 배열에 추가
        
        emit NewArt(_artId, _name, _startingPrice, now + _duration);
    }

    // 경매에 입찰하는 함수
    function placeBid(uint _artId) public payable {
        Auction storage auction = auctions[_artId];

        require(now <= auction.deadline); 
        
        // 경매가 진행중이어야 함
        require(!auction.ended);

        // 입찰 금액이 1 ETH 이상이어야 하며, 1 ETH 단위로만 거래 가능
        require(msg.value >= 1 ether && msg.value % 1 ether == 0);

        // 입찰 금액이 시작 가격보다 높아야 함
        require(msg.value > auction.currentPrice);

        // 이전 최고 입찰 금액보다 높은 경우, 이전 입찰자에게 입찰금 반환
        if (auction.highestBidder != address(0)) {
            address previousBidder = auction.highestBidder;
            previousBidder.transfer(auction.currentPrice);
        }

        // 경매 종료 시간이 1분 남았을 때 1분 추가(구매를 할 경우에만 증가됨 (6/10)
        if (auction.deadline - now <= 60) {
            auction.deadline = auction.deadline + 60;
        }
        // if(now >= auction.deadline) { //새로추가
        //     auction.ended = true;
        //     auction.status = "경매가 종료되었습니다";
        // }

        // 최고 입찰 금액과 입찰자 업데이트
        auction.currentPrice = msg.value;
        auction.highestBidder = msg.sender;

        auctions[_artId] = auction;
    }

    // 경매를 종료하는 함수
    function endAuction(uint _artId) public onlyOwner(_artId) {
        Auction storage auction = auctions[_artId];
        
        // 경매가 종료되었는지 확인
        require(now >= auction.deadline);

        // 낙찰자를 업데이트하고, 경매 소유자에게 현재 최고 입찰금 전송
        auction.winner = auction.highestBidder;
        address owner = auction.owner;
        if (auction.currentPrice > 0) {
            owner.transfer(auction.currentPrice);
        }
        auction.ended = true;
        auction.status = "경매가 종료되었습니다";
        emit AuctionEnded(_artId, auction.highestBidder, auction.currentPrice);
    }

    // 모든 미술품 id를 반환하는 함수
    function getArtIds() public view returns (uint[]) {
        return artIds;
    }

    // 스마트계약 미술품 시간 추가 함수( 6/10)
    function addTime(uint _artId, uint _addTime) public onlyOwner(_artId) {
        Auction storage auction = auctions[_artId];
        require(auction.ended == false);
        auctions[_artId].deadline += _addTime;
    }
}
