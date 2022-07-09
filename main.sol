pragma solidity 0.6.6;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IERC20.sol";
import "https://github.com/Uniswap/v2-periphery/blob/master/contracts/libraries/UniswapV2Library.sol";

contract Swap {
    address private constant addressRouter =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant addressLINK =
        0x01BE23585060835E02B77ef475b0Cc51aA1e0709;
    address private constant addressDAI =
        0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735;
    address private constant addressFactory =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

    IERC20 LINK;
    IERC20 DAI;
    IUniswapV2Router02 router;
    IUniswapV2Factory factory;

    receive() external payable {}

    fallback() external payable {}

    constructor() public {
        factory = IUniswapV2Factory(addressFactory);
        router = IUniswapV2Router02(addressRouter);
        LINK = IERC20(addressLINK);
        DAI = IERC20(addressDAI);
    }

    function swapETHtoLINK() external payable {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = addressLINK;
        uint256 deadline = block.timestamp + 120;
        router.swapExactETHForTokens{value: msg.value}(
            1,
            path,
            msg.sender,
            deadline
        );
    }

    function swapLINKtoETH(uint256 _amountLINK) external payable {
        address[] memory path = new address[](2);
        path[0] = addressLINK;
        path[1] = router.WETH();
        uint256 deadline = block.timestamp + 120;
        LINK.transferFrom(msg.sender, address(this), _amountLINK);
        LINK.approve(addressRouter, _amountLINK);
        router.swapExactTokensForETH(
            _amountLINK,
            1,
            path,
            msg.sender,
            deadline
        );
    }

    function swapLINKtoDAI(uint256 _amountLINK) external payable {
        address[] memory path = new address[](2);
        path[0] = addressLINK;
        path[1] = addressDAI;
        uint256 deadline = block.timestamp + 120;
        LINK.transferFrom(msg.sender, address(this), _amountLINK);
        LINK.approve(addressRouter, _amountLINK);
        router.swapExactTokensForTokens(
            _amountLINK,
            1,
            path,
            msg.sender,
            deadline
        );
    }

    uint256 public LINK_ETH_LP;

    function getNeededLINK(uint256 _amountETH) public view returns (uint256) {
        uint256 reserveLINK;
        uint256 reserveETH;
        uint256 neededLINK;
        (reserveLINK, reserveETH) = UniswapV2Library.getReserves(
            addressFactory,
            addressLINK,
            router.WETH()
        );
        neededLINK = UniswapV2Library.quote(
            _amountETH,
            reserveETH,
            reserveLINK
        );
        return neededLINK;
    }

    function getBalanceLINK_ETH_LP() external view returns (uint256) {
        address pairaddr = getPairLink_ETH();
        return IERC20(pairaddr).balanceOf(msg.sender);
    }

    function addLiquidityLINK_ETH(uint256 _amountLINK)
        external
        payable
        returns (uint256)
    {
        LINK.transferFrom(msg.sender, address(this), _amountLINK);
        LINK.approve(addressRouter, _amountLINK);
        uint256 deadline = block.timestamp + 120;
        (, , LINK_ETH_LP) = router.addLiquidityETH{value: msg.value}(
            addressLINK,
            _amountLINK,
            1,
            1,
            msg.sender,
            deadline
        );
        return LINK_ETH_LP;
    }

    function getPairLink_ETH() public view returns (address) {
        return factory.getPair(addressLINK, router.WETH());
    }

    function removeLiquidityLINK_ETH(uint256 _amountLP) external payable {
        address pairAddress = getPairLink_ETH();
        IERC20(pairAddress).transferFrom(msg.sender, address(this), _amountLP);
        IERC20(pairAddress).approve(addressRouter, _amountLP);
        uint256 deadline = block.timestamp + 120;
        address token = addressLINK;
        router.removeLiquidityETH(token, _amountLP, 1, 1, msg.sender, deadline);
    }

    uint256 public LINK_DAI_LP;

    function getNeededDAI(uint256 _amountLINK) public view returns (uint256) {
        uint256 reserveLINK;
        uint256 reserveDAI;
        uint256 neededDAI;
        (reserveLINK, reserveDAI) = UniswapV2Library.getReserves(
            addressFactory,
            addressLINK,
            addressDAI
        );
        neededDAI = UniswapV2Library.quote(
            _amountLINK,
            reserveLINK,
            reserveDAI
        );
        return neededDAI;
    }

    function getBalanceLINK_DAI_LP() external view returns (uint256) {
        address pairaddr = getPairLinkDAI();
        return IERC20(pairaddr).balanceOf(msg.sender);
    }

    function addLiquidityLINK_DAI(uint256 _amountLINK, uint256 _amountDAI)
        external
        payable
        returns (uint256)
    {
        LINK.transferFrom(msg.sender, address(this), _amountLINK);
        LINK.approve(addressRouter, _amountLINK);
        DAI.transferFrom(msg.sender, address(this), _amountDAI);
        DAI.approve(addressRouter, _amountDAI);
        uint256 deadline = block.timestamp + 120;
        (, , LINK_DAI_LP) = router.addLiquidity(
            addressLINK,
            addressDAI,
            _amountLINK,
            _amountDAI,
            1,
            1,
            msg.sender,
            deadline
        );
        return LINK_DAI_LP;
    }

    function getPairLinkDAI() public view returns (address) {
        return factory.getPair(addressLINK, addressDAI);
    }

    function removeLiquidityLINK_DAI(uint256 _amountLP) external payable {
        address pairAddress = getPairLinkDAI();
        IERC20(pairAddress).transferFrom(msg.sender, address(this), _amountLP);
        IERC20(pairAddress).approve(addressRouter, _amountLP);
        uint256 deadline = block.timestamp + 120;
        router.removeLiquidity(
            addressLINK,
            addressDAI,
            _amountLP,
            1,
            1,
            msg.sender,
            deadline
        );
    }
}
