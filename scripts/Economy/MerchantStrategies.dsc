MerchantStrategy_Qualifiers:
    type: data
    strategy_list:
        Buy_Expensive:
            # Relevant stats in MerchantData will be listed here as keys
            balance:
                # Tolerance dictates the extent to which this value needs to match the merchant's
                # observed value. The higher the tolerance the greater the error allowed will be.
                ## Warning! Tolerance values above 10 will lead to strange outcomes and unpredictable
                ##          merchant behaviour.
                tolerance: 0.8
                # Can also be 'max', or 'is'
                min: 7000
            # The extent to which the merchant will want to spend all of their money/allowance
            # A value closer to 1 will mean the merchant will spend more.
            spendBias:
                min: 0.535
            # How much of each item the merchant will want to buy. A value closer to 1 will
            # make the merchant want to maximize the amount of items to buy.
            quantityBias:
                is: 0.45
                tolerance: 0.7
        Buy_Cheap:
            balance:
                max: 5000
            spendBias:
                is: 0.35
                tolerance: 2.5
            quantityBias:
                min: 0.45
        Buy_Lots:
            balance:
                min: 3000
            spendBias:
                min: 0.5
            quantityBias:
                is: 0.65
                tolerance: 0.7
        Buy_Frugal:
            balance:
                max: 5000
            spendBias:
                min: 0.65
            quantityBias:
                is: 0.4
                tolerance: 0.5

MerchantStrategy_Behaviour:
    type: data
    strategy_list:
        Buy_Expensive:
            # The range of prices the merchant should be filtering items to be between
            price_filter:
                low: 50
                high: 100
                bias: 0.7
            price_shift: 0.55
            # Dictates the number of times the merchant will loop over the priceControlledItems
            # to top up supplies
            ## Warning! This option impacts performance heavily! Use Carefully!
            # @Default val: 2
            # @Maximum val: 7
            loop_iterations: 2
        Buy_Cheap:
            price_filter:
                low: 0
                high: 25
                bias: 0.5
            # Acts as a fallback when no items within the merchant's category are within their
            # the price_filter range.
            # If ommitted, merchant will use price_filter.shift as a fallback.
            price_shift: 0.37
            loop_iterations: 4
        Buy_Lots:
            price_filter:
                low: 0
                high: 40
                bias: 0.2
            price_shift: 0.4
            loop_iterations: 4
        Buy_Frugal:
            price_filter:
                low: 0
                high: 70
                bias: 0.4
            price_shift: 0.4
            loop_iterations: 2