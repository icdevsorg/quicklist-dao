# quicklist-dao

Runs the business logic of https://icdevs.org/BuilderDAO.html

# 🏗 "Builders Too Busy to Pay Attention to Your Allow-List But Will Support You When its Time" DAO

ICDevs.org has commissioned a DAO to help community developers gain recongnition for their work building up the Interent Computer ecosystem.

The DAO can be found [here](https://77i6o-oqaaa-aaaag-qbm6q-cai.ic0.app/axon/4).

This is a Simple DAO. It lets developers record their principal in a central place where other project owners can find them and send them drops, bonuses, and other assets the may be good for testing and/or launching new efforts on the network.

Only other developers can add you to the list.  Reach out to admin @ icdevs.org or [https://twitter.com/icdevs_org](https://twitter.com/icdevs_org) if you would like to be considered to be added to the list. You need to provide:

1. Enough evidence of developing on the IC to convince a proposer to add the vote. If there is evidence you would not like added to the ballot, let us know.
2. A principal(plug compatible for now...we hope to add all wallets soon.  Don't use an NNS principal or you won't be abel to vote.)
3. A pithy message that you would like to be shown on the public DAO web page.

You can see the current list at [https://pnbcw-3qaaa-aaaag-qbpqq-cai.raw.ic0.app/](https://pnbcw-3qaaa-aaaag-qbpqq-cai.raw.ic0.app/).

A csv version is available at [https://pnbcw-3qaaa-aaaag-qbpqq-cai.raw.ic0.app/list](https://pnbcw-3qaaa-aaaag-qbpqq-cai.raw.ic0.app/list).

You can access the list programmatically at [pnbcw-3qaaa-aaaag-qbpqq-cai](https://icscan.io/canister/pnbcw-3qaaa-aaaag-qbpqq-cai) with the following interface:

```
service : {
  getList: () -> (vec record {
                        principal;
                        record {
                          text;
                          int;
                        };
                      }) query;
  onList: (principal) -> (opt int) query;
}
```