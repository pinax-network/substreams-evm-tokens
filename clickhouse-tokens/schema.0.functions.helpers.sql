CREATE OR REPLACE FUNCTION to_version AS (block_num, transaction_index, instruction_index) ->
    block_num * 1e6 + transaction_index * 1e3 + instruction_index;