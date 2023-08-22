# SoulSwapKit.Swift

`SoulSwapKit.Swift` extends `EvmKit.Swift` to support `Uniswap` DEX and some other DEXes using the same smart contract codebase. Currently, `UnstoppableWallet` uses this kit for integration of `Uniswap`(Ethereum), `PancakeSwap`(BSC), `QuickSwap`(Polygon) and `Trader Joe`(Avalanche)

## Features

- ExactIn/ExactOut trades
- Price Impact/Deadline/Recipient options 
- Fee on Transfer

## Usage

### Initialization

```swift
import EvmKit
import SoulSwapKit

let evmKit = try Kit.instance(
	address: try EvmKit.Address(hex: "0x..user..address.."),
	chain: .ethereum,
	rpcSource: .ethereumInfuraWebsocket(projectId: "...", projectSecret: "..."),
	transactionSource: .ethereumEtherscan(apiKey: "..."),
	walletId: "unique_wallet_id",
	minLogLevel: .error
)

let soulSwapKit = SoulSwapKit.Kit.instance(evmKit: evmKit)

// Decorators are needed to detect and decorate transactions as `Uniswap` transactions
SoulSwapKit.Kit.addDecorators(to: evmKit)
```

### Send sample swap transaction

```swift
// Get Signer object
let seed = Mnemonic.seed(mnemonic: ["mnemonic", "words", ...])!
let signer = try Signer.instance(seed: seed, chain: .ethereum)

// Sample swap data
let tokenIn = soulSwapKit.etherToken
let tokenOut = soulSwapKit.token(contractAddress: try! EvmKit.Address(hex: "0x..token..address"), decimals: 18)
let amount: Decimal = 0.1
let gasPrice = GasPrice.legacy(gasPrice: 50_000_000_000)

// Get SwapData. SwapData is a list of pairs available in Uniswap smart contract at the moment
let transactionDataSingle: Single<TransactionData> = soulSwapKit.swapDataSingle(tokenIn: tokenIn, tokenOut: tokenOut)
    .map { swapData in
        // Get TradeData. TradeData is the best swap route evaluated by SoulSwapKit
        let tradeData = try! soulSwapKit.bestTradeExactIn(swapData: swapData, amountIn: amount)
        
        // Convert TradeData to EvmKit TransactionData
        return try! soulSwapKit.transactionData(tradeData: tradeData)
    }

// Estimate gas for the transaction
let estimateGasSingle = transactionDataSingle.flatMap { transactionData in
    evmKit.estimateGas(transactionData: transactionData, gasPrice: gasPrice)
}

// Generate a raw transaction which is ready to be signed. This step also synchronizes the nonce
let rawTransactionSingle = estimateGasSingle.flatMap { estimatedGasLimit in
    evmKit.rawTransaction(transactionData: transactionData, gasPrice: gasPrice, gasLimit: estimatedGasLimit)
}

let sendSingle = rawTransactionSingle.flatMap { rawTransaction in
    // Sign the transaction
    let signature = try signer.signature(rawTransaction: rawTransaction)
    
    // Send the transaction to RPC node
    return evmKit.sendSingle(rawTransaction: rawTransaction, signature: signature)
}

let disposeBag = DisposeBag()

sendSingle
    .subscribe(
        onSuccess: { fullTransaction in
            let transaction = fullTransaction.transaction
            print("Transaction sent: \(transaction.hash.hs.hexString)")
        }, onError: { error in
            print("Send failed: \(error)")
        }
    )
    .disposed(by: disposeBag)
```

### ExactIn/ExactOut

With `SoulSwapKit` you can build swap transaction that either has an exact `In` or exact `Out` amount. That is, if you want to swap exactly 1 ETH to USDT, you get `TradeData` using `bestTradeExactIn` method. Similarly, if you want to swap ETH to USDT and you want to get exactly 1000 USDT, then you get `TradeData` using `bestTradeExactOut`

### Trade Options

`SoulSwapKit` supports `Price Impact/Deadline/Recipient` options. You can set them in `TradeOptions` object passed to `bestTradeExactIn/bestTradeExactOut` methods. Please, look at official Uniswap app documentation to learn about those options.

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/horizontalsystems/SoulSwapKit.Swift.git", .upToNextMajor(from: "1.0.0"))
]
```

## License

The `SoulSwapKit.Swift` toolkit is open source and available under the terms of the [MIT License](https://github.com/horizontalsystems/ethereum-kit-ios/blob/master/LICENSE).

