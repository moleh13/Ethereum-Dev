// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract Enum {
    enum Status {
        None,
        Pending,
        Shipped,
        Completed,
        Rejected,
        Cancelled
    }

    Status public status;

    struct Order {
        address buyer;
        Status status;
    }
}